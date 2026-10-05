#!/usr/bin/env python3
"""Synthetic actual release-gate fixtures; no app launch, signing, keys or user data."""
import copy
import json
import os
import pathlib
import plistlib
import subprocess
import tempfile

repository = pathlib.Path(__file__).resolve().parent.parent
scanner = repository / "scripts/verify-app-security.py"
common = repository / "scripts/release-common.sh"
with (repository / "resources/Info.plist").open("rb") as stream:
    baseline = plistlib.load(stream)
baseline.update(SURequireSignedFeed=True, SUVerifyUpdateBeforeExtraction=True,
                SUSignedFeedFailureExpirationInterval=0, SHOTCLIPBuildFlavor="production",
                SHOTCLIPSourceCommit="a" * 40, SHOTCLIPReleaseMode="ad-hoc")
checks = []
with tempfile.TemporaryDirectory(prefix="shotclip-security-fixtures.") as temporary:
    bundle = pathlib.Path(temporary) / "Shot Clip.app"
    executable = bundle / "Contents/MacOS/shotclip"
    executable.parent.mkdir(parents=True)
    resources = bundle / "Contents/Resources/shotclip_shotclip.bundle/Contents/Resources"
    for language in ("en", "ko"):
        folder = resources / (language + ".lproj")
        folder.mkdir(parents=True)
        for table in ("Localizable", "Updates"):
            (folder / (table + ".strings")).write_text('"fixture" = "Synthetic";\n')
    payload = resources / "fixture.bin"
    plist = bundle / "Contents/Info.plist"
    def reset():
        plist.write_bytes(plistlib.dumps(baseline))
        executable.write_bytes(b"synthetic nonexecuted main")
        payload.unlink(missing_ok=True)
    def run(label, expected=True, category=None):
        # Only codesign is replaced with a fixture. All metadata/resource/security
        # checks are the actual release_verify_bundle implementation.
        command = '''source "$1"
SHOTCLIP_VERSION="$3"; SHOTCLIP_BUILD_NUMBER="$4"; SHOTCLIP_RELEASE_MODE=ad-hoc
codesign() { if [[ "$1" == -dv ]]; then printf 'Signature=adhoc\\nTeamIdentifier=not set\\n'; fi; }
release_verify_bundle "$2" aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'''
        result = subprocess.run(["bash", "-c", command, "fixture", str(common), str(bundle),
                                 baseline["CFBundleShortVersionString"], baseline["CFBundleVersion"]],
                                capture_output=True, text=True, cwd=repository)
        if (result.returncode == 0) != expected or (category and category not in result.stdout):
            raise SystemExit("FAIL: " + label)
        checks.append({"case": label, "expected": "accept" if expected else "reject", "result": "PASS"})
    reset(); run("valid-production-policy-and-artifact")
    changed = copy.deepcopy(baseline)
    changed.pop("SURequireSignedFeed")
    changed["SUSignedFeedFailureExpirationInterval"] = 1728000
    plist.write_bytes(plistlib.dumps(changed))
    environment = dict(os.environ)
    environment.pop("SHOTCLIP_UPDATE_FEED_URL", None)
    environment.pop("SHOTCLIP_UPDATE_PUBLIC_KEY", None)
    configured = subprocess.run(["/usr/bin/swift", str(repository / "scripts/configure-updates.swift"), str(plist)],
                                capture_output=True, env=environment)
    if configured.returncode: raise SystemExit("FAIL: strict feed configuration")
    run("configuration-replaces-missing-policy-and-expiring-fallback")
    for label, value in [("missing", None), ("twenty-days", 1728000), ("negative", -1),
                         ("string-zero", "0"), ("boolean-false", False), ("float-zero", 0.0)]:
        reset(); changed = copy.deepcopy(baseline)
        if value is None: changed.pop("SUSignedFeedFailureExpirationInterval")
        else: changed["SUSignedFeedFailureExpirationInterval"] = value
        plist.write_bytes(plistlib.dumps(changed)); run("feed-expiration-" + label, False, "signed-feed-expiration")
    for label, value in [("missing", None), ("false", False), ("string-true", "true")]:
        reset(); changed = copy.deepcopy(baseline)
        if value is None: changed.pop("SURequireSignedFeed")
        else: changed["SURequireSignedFeed"] = value
        plist.write_bytes(plistlib.dumps(changed)); run("signed-feed-policy-" + label, False)
    for label, value in [("missing", None), ("false", False), ("string-true", "true")]:
        reset(); changed = copy.deepcopy(baseline)
        if value is None: changed.pop("SUVerifyUpdateBeforeExtraction")
        else: changed["SUVerifyUpdateBeforeExtraction"] = value
        plist.write_bytes(plistlib.dumps(changed)); run("archive-before-extraction-" + label, False)
    for label, root in [("array", []), ("string", "synthetic"), ("integer", 3), ("malformed", None)]:
        reset(); plist.write_bytes(plistlib.dumps(root) if root is not None else b"not a plist")
        scanned = subprocess.run(["python3", str(scanner), str(bundle)], capture_output=True)
        if scanned.returncode != 1 or scanned.stderr or "bundle-plist" not in json.loads(scanned.stdout)["categories"]:
            raise SystemExit("FAIL: controlled plist rejection " + label)
        checks.append({"case": "plist-root-" + label, "expected": "reject", "result": "PASS"})
    for value in (None, "qa"):
        reset(); changed = copy.deepcopy(baseline)
        if value is None: changed.pop("SHOTCLIPBuildFlavor")
        else: changed["SHOTCLIPBuildFlavor"] = value
        plist.write_bytes(plistlib.dumps(changed)); run("flavor-" + str(value), False, "production-flavor")
    for prefix in ("/Users/synthetic/", "/USERS/synthetic/", "/home/synthetic/", "/HOME/synthetic/",
                   "/uSeRs/owner", "/hOmE/owner"):
        for encoding in ("utf-8", "utf-16-le", "utf-16-be"):
            for offset in (0, 1):
                reset(); payload.write_bytes(b"x" * offset + (prefix + "source.swift").encode(encoding))
                run("personal-path-" + prefix.split('/')[1] + "-" + encoding + "-offset" + str(offset), False, "personal-path-metadata")
    for encoding in ("utf-8", "utf-16-le", "utf-16-be"):
        reset(); payload.write_bytes((str(repository) + "/Sources/synthetic.swift").encode(encoding))
        run("workspace-path-" + encoding, False, "workspace-path-metadata")
    reset(); payload.write_bytes(b"/synthetic/project/.build/release/main")
    run("absolute-scratch-path", False, "absolute-build-metadata")
    for marker in (b"UIPreview", b"SelfTest", b"beforePNGWriteForPreview", b"shotclip-fixture.app", b"resource_bundle_accessor"):
        reset(); executable.write_bytes(b"synthetic " + marker)
        run("production-qa-" + marker.decode(), False, "production-qa-code")
    reset(); payload.write_bytes(b"beforePNGWriteForPreview")
    run("own-resource-qa-payload", False, "production-qa-code")
    reset(); named = resources / "UIPreview.fixture"; named.write_bytes(b"synthetic")
    run("own-resource-qa-filename", False, "production-qa-code"); named.unlink()
    reset(); payload.symlink_to("missing-synthetic-target")
    run("broken-relative-symlink", False, "escaping-or-broken-symlink")
    reset(); payload.symlink_to("/Users/synthetic/missing")
    run("personal-escaping-symlink", False, "personal-path-metadata")
    reset()
    source = pathlib.Path(temporary) / "fixture.c"
    source.write_text("int main(void) { return 0; }\n")
    for path, accepted in [("/usr/lib/swift", True), ("@loader_path", True), ("@executable_path", True), ("@loader_path/../../../../external", False),
                           ("@executable_path/../../../../external", False), ("/synthetic/scratch", False)]:
        result = subprocess.run(["/usr/bin/clang", str(source), "-Wl,-rpath," + path, "-o", str(executable)], capture_output=True)
        if result.returncode: raise SystemExit("FAIL: Mach-O fixture compilation")
        run("macho-allowed-rpath-" + path if accepted else "macho-unsafe-rpath", accepted,
            None if accepted else "absolute-or-unsafe-rpath")
    rejected = subprocess.run(["python3", str(repository / "scripts/remove-toolchain-rpaths.py"), str(executable)], capture_output=True)
    if rejected.returncode == 0: raise SystemExit("FAIL: unknown RPATH silently removed")
    checks.append({"case": "unknown-rpath-removal", "expected": "reject", "result": "PASS"})
    target = subprocess.run(["/usr/bin/xcrun", "swiftc", "-print-target-info"], capture_output=True, text=True, check=True)
    toolchain = next(path for path in json.loads(target.stdout)["paths"]["runtimeLibraryPaths"] if path != "/usr/lib/swift")
    compiled = subprocess.run(["/usr/bin/clang", str(source), "-Wl,-rpath," + toolchain, "-o", str(executable)], capture_output=True)
    if compiled.returncode: raise SystemExit("FAIL: toolchain RPATH fixture")
    removed = subprocess.run(["python3", str(repository / "scripts/remove-toolchain-rpaths.py"), str(executable)], capture_output=True)
    if removed.returncode or json.loads(removed.stdout)["removed"] != 1:
        raise SystemExit("FAIL: verified toolchain RPATH removal")
    run("verified-toolchain-rpath-removal")
print(json.dumps({"case": "app-security-fixtures", "result": "PASS", "checks": checks,
                  "accepted": sum(c["expected"] == "accept" for c in checks),
                  "rejected": sum(c["expected"] == "reject" for c in checks),
                  "realAppLaunched": False, "codesignStubOnlyInFixtures": True}, sort_keys=True))
