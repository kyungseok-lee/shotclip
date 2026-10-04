#!/usr/bin/env python3
"""Synthetic archive safety checks; never extracts or accesses installed apps."""
import pathlib
import stat
import subprocess
import tempfile
import warnings
import zipfile

warnings.filterwarnings("ignore", category=UserWarning, module="zipfile")
verifier = pathlib.Path(__file__).with_name("verify-release-archive.py")
base = [("Shot Clip.app/Contents/Info.plist", b"synthetic plist"),
        ("Shot Clip.app/Contents/MacOS/shotclip", b"synthetic executable")]

def link(name, target):
    info = zipfile.ZipInfo(name)
    info.create_system = 3
    info.external_attr = (stat.S_IFLNK | 0o777) << 16
    return info, target.encode()

with tempfile.TemporaryDirectory(prefix="shotclip-archive-check.") as tmp:
    def run(name, extras, expected, entries=base):
        path = pathlib.Path(tmp) / (name + ".zip")
        with zipfile.ZipFile(path, "w") as archive:
            for item, data in entries + extras:
                archive.writestr(item, data)
        result = subprocess.run(["python3", str(verifier), str(path)], capture_output=True, text=True)
        if (result.returncode == 0) != expected:
            raise SystemExit(f"FAIL: {name}: {result.stderr}")

    run("valid", [link("Shot Clip.app/Contents/Frameworks/Sparkle.framework/Versions/Current", "B")], True)
    run("valid-ditto-metadata", [
        ("__MACOSX/", b""),
        ("__MACOSX/Shot Clip.app/", b""),
        ("__MACOSX/._Shot Clip.app", b"synthetic AppleDouble"),
        ("__MACOSX/Shot Clip.app/Contents/", b""),
        ("__MACOSX/Shot Clip.app/Contents/._Info.plist", b"synthetic AppleDouble"),
        ("__MACOSX/Shot Clip.app/Contents/MacOS/", b""),
        ("__MACOSX/Shot Clip.app/Contents/MacOS/._shotclip", b"synthetic AppleDouble"),
    ], True)
    old_root = [("ShotClip.app/Contents/Info.plist", b"synthetic old plist"),
                ("ShotClip.app/Contents/MacOS/shotclip", b"synthetic old executable")]
    run("old-name-root", [], False, entries=old_root)
    run("mixed-app-roots", old_root, False)
    for name, path in [("traversal", "../outside"), ("absolute", "/outside"), ("extra-app", "Other.app/Info.plist")]:
        run(name, [(path, b"bad")], False)
    run("escape-symlink", [link("Shot Clip.app/Contents/escape", "../../../outside")], False)
    run("absolute-symlink", [link("Shot Clip.app/Contents/escape", "/outside")], False)
    run("dot-dot-alias", [link("Shot Clip.app/Contents/inside", "../Contents")], False)
    run("symlink-parent", [link("Shot Clip.app/Contents/extra", "Resources"), ("Shot Clip.app/Contents/extra/file", b"bad")], False)
    run("duplicate", [("Shot Clip.app/Contents/Info.plist", b"duplicate")], False)
    run("metadata-root-file", [("__MACOSX/Shot Clip.app", b"bad")], False)
    metadata_root_file = zipfile.ZipInfo("__MACOSX/Shot Clip.app/")
    metadata_root_file.create_system = 3
    metadata_root_file.external_attr = (stat.S_IFREG | 0o644) << 16
    run("metadata-root-file-with-slash", [(metadata_root_file, b"bad")], False)
    run("metadata-root-symlink", [link("__MACOSX/Shot Clip.app/", "Shot Clip.app")], False)
    run("metadata-extra-app", [("__MACOSX/Other.app/", b"")], False)
    run("metadata-traversal", [("__MACOSX/Shot Clip.app/../outside", b"bad")], False)
print("PASS: spaced app root, valid framework symlink and ditto metadata; 15 unsafe/old-or-mixed-root cases rejected; no app extraction/installation")
