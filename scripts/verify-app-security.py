#!/usr/bin/env python3
"""Read-only production bundle gates; reports categories/counts, never matched paths."""
import argparse
import json
import os
import pathlib
import plistlib
import re
import stat
import subprocess
import sys

QA_MARKERS = [b"UIPreview", b"UpdatePreview", b"CapturePreviewQA", b"SelfTest",
              b"ForPreview", b"previewStructuralViews", b"previewGeometry", b"previewLayout",
              b"previewControls", b"previewToolbar", b"previewCaptions", b"auditEvidence",
              b"configureSavePanelForPreview", b"beforePNGWriteForPreview", b"onSavePanelPresented",
              b"onSaveFailure", b"shotclip-fixture.app", b"resource_bundle_accessor", b"Bundle.module"]
MACHO_MAGIC = {bytes.fromhex(value) for value in
               ["feedface", "cefaedfe", "feedfacf", "cffaedfe", "cafebabe", "bebafeca", "cafebabf", "bfbafeca"]}

def inspect(bundle, policy_only=False):
    failures = set()
    counts = {"regularFiles": 0, "symlinks": 0, "machOFiles": 0, "personalPaths": 0,
              "workspacePaths": 0, "buildPaths": 0, "qaMarkers": 0, "unsafeRpaths": 0}
    plist_path = bundle / "Contents/Info.plist"
    try:
        if plist_path.is_symlink():
            raise ValueError("symlink plist")
        with plist_path.open("rb") as stream:
            info = plistlib.load(stream)
        if not isinstance(info, dict):
            raise ValueError("non-dictionary plist")
        if info.get("SURequireSignedFeed") is not True or info.get("SUVerifyUpdateBeforeExtraction") is not True:
            failures.add("signed-update-policy")
        # bool, strings, floats and absent values must not impersonate integer 0.
        interval = info.get("SUSignedFeedFailureExpirationInterval")
        if type(interval) is not int or interval != 0:
            failures.add("signed-feed-expiration")
        if info.get("SHOTCLIPBuildFlavor") != "production":
            failures.add("production-flavor")
    except (OSError, ValueError, plistlib.InvalidFileException):
        failures.add("bundle-plist")
    if policy_only:
        return failures, counts

    markers = {str(pathlib.Path.cwd().absolute()), str(pathlib.Path.cwd().resolve())}
    lexical = os.environ.get("PWD")
    if lexical and pathlib.Path(lexical).resolve() == pathlib.Path.cwd().resolve():
        markers.add(lexical)
    patterns = [rb"/(?:Users|home)/", rb"/[A-Za-z0-9_. /-]+/\.build/"]
    def scan(data, main=False):
        # Inspect raw and UTF-16 encodings without emitting private contents.
        views = [data]
        for encoding in ("utf-16-le", "utf-16-be"):
            for offset in (0, 1):
                views.append(data[offset:].decode(encoding, errors="ignore").encode("utf-8"))
        for view in views:
            counts["personalPaths"] += len(re.findall(patterns[0], view, re.IGNORECASE))
            counts["buildPaths"] += len(re.findall(patterns[1], view, re.IGNORECASE))
            counts["workspacePaths"] += sum(view.lower().count(marker.lower().encode()) for marker in markers)
            if main:
                counts["qaMarkers"] += sum(view.count(marker) for marker in QA_MARKERS)
    if not bundle.is_dir() or bundle.is_symlink():
        failures.add("bundle-root")
        return failures, counts
    for directory, dirs, files in os.walk(bundle, followlinks=False):
        for name in dirs + files:
            path = pathlib.Path(directory) / name
            relative = path.relative_to(bundle)
            mode = path.lstat().st_mode
            app_owned = not str(relative).startswith("Contents/Frameworks/")
            if app_owned:
                scan(str(relative).encode(), main=True)
            if stat.S_ISLNK(mode):
                counts["symlinks"] += 1
                target = os.readlink(path)
                scan(target.encode())
                # Standard versioned framework links must remain inside the app.
                try:
                    path.resolve(strict=True).relative_to(bundle.resolve())
                except (OSError, RuntimeError, ValueError):
                    failures.add("escaping-or-broken-symlink")
                continue
            if not stat.S_ISREG(mode):
                if not stat.S_ISDIR(mode):
                    failures.add("nonregular-file")
                continue
            counts["regularFiles"] += 1
            data = path.read_bytes()
            scan(data, main=app_owned)
            if data[:4] in MACHO_MAGIC:
                counts["machOFiles"] += 1
                result = subprocess.run(["/usr/bin/otool", "-l", str(path)], capture_output=True, text=True)
                if result.returncode:
                    failures.add("mach-o-inspection")
                    continue
                header = subprocess.run(["/usr/bin/otool", "-hv", str(path)], capture_output=True, text=True)
                executable_base = path.parent if "EXECUTE" in header.stdout else bundle / "Contents/MacOS"
                def safe_rpath(value):
                    if value == "/usr/lib/swift":
                        return True
                    for token, base in [("@loader_path", path.parent), ("@executable_path", executable_base)]:
                        if value == token or value.startswith(token + "/"):
                            suffix = value[len(token):].removeprefix("/")
                            try:
                                (base / suffix).resolve().relative_to(bundle.resolve())
                                return True
                            except (OSError, RuntimeError, ValueError):
                                return False
                    return False
                commands = result.stdout.split("Load command ")
                for command in commands:
                    if "cmd LC_RPATH\n" in command:
                        match = re.search(r"\n\s*path (.*?) \(offset", command)
                        if not match or not safe_rpath(match.group(1)):
                            counts["unsafeRpaths"] += 1
                if "sectname __debug_" in result.stdout:
                    failures.add("distributed-debug-info")
    for key, category in [("personalPaths", "personal-path-metadata"), ("workspacePaths", "workspace-path-metadata"),
                          ("buildPaths", "absolute-build-metadata"), ("qaMarkers", "production-qa-code"),
                          ("unsafeRpaths", "absolute-or-unsafe-rpath")]:
        if counts[key]:
            failures.add(category)
    return failures, counts

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("bundle", type=pathlib.Path)
    parser.add_argument("--policy-only", action="store_true")
    args = parser.parse_args()
    try:
        failures, counts = inspect(args.bundle, args.policy_only)
    except (OSError, ValueError):
        failures, counts = {"unreadable-artifact"}, {}
    print(json.dumps({"case": "production-app-security", "result": "FAIL" if failures else "PASS",
                      "categories": sorted(failures), "counts": counts}, sort_keys=True))
    return 1 if failures else 0

if __name__ == "__main__":
    sys.exit(main())
