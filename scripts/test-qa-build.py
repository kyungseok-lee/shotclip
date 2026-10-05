#!/usr/bin/env python3
"""Verify an isolated portable QA bundle without normal startup or real capture."""
import json
import pathlib
import shutil
import subprocess
import sys
import tempfile

source = pathlib.Path(sys.argv[1]).resolve()
with tempfile.TemporaryDirectory(prefix="shotclip-qa-isolation.") as temporary:
    bundle = pathlib.Path(temporary) / "Shot Clip QA.app"
    shutil.copytree(source, bundle, symlinks=True)
    executable = bundle / "Contents/MacOS/shotclip"
    for arguments in ([], ["--unknown-qa-route"], ["--self-test=synthetic"]):
        result = subprocess.run([str(executable), *arguments], capture_output=True, timeout=10)
        if result.returncode != 64 or result.stdout:
            raise SystemExit("FAIL: QA normal route was not rejected")
    positive = subprocess.run([str(executable), "--localization-self-test"], capture_output=True, timeout=10)
    if positive.returncode or json.loads(positive.stdout).get("installedBundle") is not True:
        raise SystemExit("FAIL: portable QA resources")
    resources = bundle / "Contents/Resources/shotclip_shotclip.bundle"
    resources.rename(resources.with_name("unavailable.bundle"))
    negative = subprocess.run([str(executable), "--localization-self-test"], capture_output=True, timeout=10)
    if negative.returncode != 78 or negative.stdout or b"resources are missing" not in negative.stderr:
        raise SystemExit("FAIL: absent QA resources used an external fallback")
print(json.dumps({"case": "portable-qa-build", "result": "PASS", "normalRoutesRejected": 3,
                  "installedLocalization": True, "missingResourcesRejected": True,
                  "checkoutAdjacentResources": False, "absoluteBuildFallback": False,
                  "realCaptureTested": False}, sort_keys=True))
