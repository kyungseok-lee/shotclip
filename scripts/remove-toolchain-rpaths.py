#!/usr/bin/env python3
"""Remove only verified active-toolchain stdlib RPATHs before signing an app."""
import json
import pathlib
import re
import subprocess
import sys

executable = pathlib.Path(sys.argv[1])
info = subprocess.run(["/usr/bin/xcrun", "swiftc", "-print-target-info"], capture_output=True, text=True, check=True)
paths = json.loads(info.stdout)["paths"]
resource = pathlib.Path(paths["runtimeResourcePath"])
known = set(paths["runtimeLibraryPaths"]) - {"/usr/lib/swift"}
# Swift Build may add a versioned compatibility library directory independently
# of the Swift driver. Accept only existing stdlib directories in this toolchain.
for directory in resource.parent.glob("swift-*"):
    candidate = directory / "macosx"
    if candidate.is_dir() and candidate.resolve().is_relative_to(resource.parent.resolve()):
        known.add(str(candidate))
commands = subprocess.run(["/usr/bin/otool", "-l", str(executable)], capture_output=True, text=True, check=True).stdout
removed = 0
for command in commands.split("Load command "):
    if "cmd LC_RPATH\n" not in command:
        continue
    match = re.search(r"\n\s*path (.*?) \(offset", command)
    if not match:
        raise SystemExit("Unable to inspect an app RPATH.")
    value = match.group(1)
    if value in known:
        # Apple's tool invalidates any prior signature; build-app signs afterward.
        subprocess.run(["/usr/bin/install_name_tool", "-delete_rpath", value, str(executable)],
                       check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        removed += 1
    elif not (value == "/usr/lib/swift" or value in ("@loader_path", "@executable_path")
              or value.startswith(("@loader_path/", "@executable_path/"))):
        raise SystemExit("Unrecognized absolute app RPATH; refusing to remove it.")
print(json.dumps({"case": "app-toolchain-rpaths", "result": "PASS", "removed": removed}, sort_keys=True))
