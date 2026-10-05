#!/usr/bin/env python3
"""Run retired argv only; every case must exit before normal startup or any QA."""
import hashlib
import json
import pathlib
import plistlib
import shutil
import subprocess
import sys
import tempfile

source = pathlib.Path(sys.argv[1]).resolve()
flags = ["--self-test", "--ui-preview", "--localization-self-test", "--language", "--appearance",
         "--updater-only", "--capture-preview-only", "--native-save-panel", "--native-menu",
         "--settings-only", "--native-save-manual", "--native-save-error-ui", "--display-index"]
def preferences():
    result = {}
    for domain in ("dev.shotclip.app", "dev.shotclip.qa", "dev.sshot.app"):
        exported = subprocess.run(["/usr/bin/defaults", "export", domain, "-"], capture_output=True)
        try:
            data = plistlib.dumps(plistlib.loads(exported.stdout), sort_keys=True)
        except (ValueError, plistlib.InvalidFileException):
            data = b"absent"
        result[domain] = hashlib.sha256(data).hexdigest()
    return result
before = preferences()
with tempfile.TemporaryDirectory(prefix="shotclip-retired-argv.") as temporary:
    root = pathlib.Path(temporary)
    app = root / "Shot Clip.app"
    shutil.copytree(source, app, symlinks=True)
    marker = root / "helper-executed"
    helper = root / "shotclip-fixture.app/Contents/MacOS/shotclip-fixture"
    helper.parent.mkdir(parents=True)
    # This canary must never execute. It does not touch the desktop or clipboard.
    helper.write_text('#!/bin/sh\nprintf executed > "' + str(marker) + '"\nexit 99\n')
    helper.chmod(0o755)
    output = root / "must-not-be-created"
    cases = []
    for flag in flags:
        for arguments in ([flag], [flag + "=synthetic"]):
            result = subprocess.run([str(app / "Contents/MacOS/shotclip"), *arguments],
                                    capture_output=True, timeout=10)
            if result.returncode != 64 or result.stdout or b"unavailable" not in result.stderr:
                raise SystemExit("FAIL: early rejection " + flag)
            if marker.exists() or output.exists():
                raise SystemExit("FAIL: forbidden QA side effect")
            cases.append({"flag": flag, "equalsForm": "=" in arguments[0], "result": "PASS", "exitCode": 64})
    result = subprocess.run([str(app / "Contents/MacOS/shotclip"), "--ui-preview", str(output),
                             "--language", "ko", "--appearance", "dark", "--self-test"],
                            capture_output=True, timeout=10)
    if result.returncode != 64 or marker.exists() or output.exists():
        raise SystemExit("FAIL: combined retired routes")
    cases.append({"flag": "combined-routes", "result": "PASS", "exitCode": 64})
if before != preferences():
    raise SystemExit("FAIL: persistent application preferences changed")
print(json.dumps({"case": "production-retired-qa-arguments", "result": "PASS", "cases": cases,
                  "count": len(cases), "helperExecuted": False, "qaOutputCreated": False,
                  "persistentDomainsUnchanged": True, "normalAppLaunch": False,
                  "captureTCCClipboardKeychainTested": False}, sort_keys=True))
