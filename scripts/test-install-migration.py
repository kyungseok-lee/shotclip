#!/usr/bin/env python3
"""Exercise the real installer transaction with signed, never-launched temp apps.

No /Applications access, user preferences, TCC, clipboard or Keychain signing key.
The copied system executable is re-signed ad-hoc only inside temporary fixtures.
"""
import pathlib
import plistlib
import shutil
import subprocess
import tempfile

repository = pathlib.Path(__file__).resolve().parent.parent
runner = r'''
set -euo pipefail
source "$1/scripts/release-common.sh"
source "$1/scripts/install-common.sh"
fixture_target="$3/Shot Clip.app"
fixture_mode="$4"
fresh_verify_count=0
# Synthetic apps are never run; the temp destination cannot touch real apps.
pgrep() { return 1; }
codesign() {
    local inspected="${!#}"
    if [[ "$inspected" == "$fixture_target" && -f "$inspected/Contents/Resources/fixture-marker" && "$(cat "$inspected/Contents/Resources/fixture-marker")" == fresh ]]; then
        fresh_verify_count=$((fresh_verify_count + 1))
        if [[ "$fixture_mode" == first-failure || ( "$fixture_mode" == final-failure && "$fresh_verify_count" == 2 ) ]]; then
            printf '%s\n' 'Injected canonical verification failure' >&2
            return 79
        fi
    fi
    /usr/bin/codesign "$@"
}
install_verified_app "$2" "$3"
'''


def make_app(path, marker, *, identifier="dev.shotclip.app", name="Shot Clip", executable="shotclip", build="7"):
    (path / "Contents/MacOS").mkdir(parents=True)
    (path / "Contents/Resources").mkdir()
    info = {"CFBundleIdentifier": identifier, "CFBundleName": name,
            "CFBundleDisplayName": name, "CFBundleExecutable": executable,
            "CFBundlePackageType": "APPL", "CFBundleVersion": build,
            "CFBundleShortVersionString": "0.5.0" if build == "7" else "0.4.1"}
    with (path / "Contents/Info.plist").open("wb") as file:
        plistlib.dump(info, file)
    fixture_executable = path / "Contents/MacOS" / executable
    shutil.copyfile("/usr/bin/true", fixture_executable)
    fixture_executable.chmod(0o755)
    (path / "Contents/Resources/fixture-marker").write_text(marker)
    subprocess.run(["/usr/bin/codesign", "--force", "--sign", "-", "--identifier", identifier, str(path)],
                   check=True, capture_output=True)


def marker(path):
    return (path / "Contents/Resources/fixture-marker").read_text()


def check_signature(path):
    subprocess.run(["/usr/bin/codesign", "--verify", "--deep", "--strict", str(path)],
                   check=True, capture_output=True)


def run_install(source, applications, mode="success", expected=True):
    result = subprocess.run(["/bin/bash", "-c", runner, "fixture", str(repository), str(source),
                             str(applications), mode], capture_output=True, text=True)
    assert (result.returncode == 0) == expected, result.stderr
    return result


with tempfile.TemporaryDirectory(prefix="shotclip-install-fixtures.") as temporary:
    root = pathlib.Path(temporary)
    source = root / "Build output with spaces/Shot Clip.app"
    make_app(source, "fresh")
    checks = 0

    # New canonical path and same-ID unspaced path, without rewriting preferences.
    applications = root / "migration/Applications with spaces"
    applications.mkdir(parents=True)
    previous = applications / "ShotClip.app"
    make_app(previous, "prior", name="ShotClip", build="6")
    run_install(source, applications)
    target = applications / "Shot Clip.app"
    backup = next(applications.glob(".shotclip-install.*"))
    assert marker(target) == "fresh" and not previous.exists()
    assert marker(backup / "previous-ShotClip.app") == "prior"
    check_signature(target)
    checks += 1

    # All three previous paths have distinct, recoverable backups.
    applications = root / "coexistence/Applications"
    applications.mkdir(parents=True)
    for filename, label, name, identifier, executable in [
        ("Shot Clip.app", "canonical", "Shot Clip", "dev.shotclip.app", "shotclip"),
        ("ShotClip.app", "prior", "ShotClip", "dev.shotclip.app", "shotclip"),
        ("sshot.app", "legacy", "Sshot", "dev.sshot.app", "sshot")]:
        make_app(applications / filename, label, name=name, identifier=identifier, executable=executable, build="6")
    run_install(source, applications)
    backup = next(applications.glob(".shotclip-install.*"))
    assert marker(applications / "Shot Clip.app") == "fresh"
    assert [marker(backup / name) for name in ["previous-Shot Clip.app", "previous-ShotClip.app", "previous-sshot.app"]] == ["canonical", "prior", "legacy"]
    checks += 1

    # Reject an unrelated app before creating staging or moving prior data.
    for subject in ["source", "previous", "target"]:
        applications = root / subject / "Applications"
        applications.mkdir(parents=True)
        prior = applications / "ShotClip.app"
        make_app(prior, "untouched", name="ShotClip", identifier="dev.other.app" if subject == "previous" else "dev.shotclip.app", build="6")
        test_source = source
        if subject == "source":
            test_source = root / "wrong source/Shot Clip.app"
            make_app(test_source, "bad-source", identifier="dev.other.app")
        if subject == "target":
            make_app(applications / "Shot Clip.app", "bad-target", identifier="dev.other.app")
        run_install(test_source, applications, expected=False)
        assert marker(prior) == "untouched" and not list(applications.glob(".shotclip-install.*"))
        if subject == "target": assert marker(applications / "Shot Clip.app") == "bad-target"
        checks += 1

    # Failure before prior-path migration and after all backups restores all old paths.
    for mode in ["first-failure", "final-failure"]:
        applications = root / mode / "Applications"
        applications.mkdir(parents=True)
        for filename, label, name, identifier, executable in [
            ("Shot Clip.app", "canonical", "Shot Clip", "dev.shotclip.app", "shotclip"),
            ("ShotClip.app", "prior", "ShotClip", "dev.shotclip.app", "shotclip"),
            ("sshot.app", "legacy", "Sshot", "dev.sshot.app", "sshot")]:
            make_app(applications / filename, label, name=name, identifier=identifier, executable=executable, build="6")
        result = run_install(source, applications, mode, expected=False)
        restored = [marker(applications / name) for name in ["Shot Clip.app", "ShotClip.app", "sshot.app"]]
        assert restored == ["canonical", "prior", "legacy"], (mode, restored, result.stdout, result.stderr)
        for name in ["Shot Clip.app", "ShotClip.app", "sshot.app"]: check_signature(applications / name)
        assert marker(next(applications.glob(".shotclip-install.*")) / "failed-Shot Clip.app") == "fresh"
        checks += 1

    # A prior bundle symlink is not followed or replaced.
    applications = root / "symlink/Applications"
    applications.mkdir(parents=True)
    previous = applications / "ShotClip.app"
    previous.symlink_to(source)
    run_install(source, applications, expected=False)
    assert previous.is_symlink() and marker(source) == "fresh"
    assert not list(applications.glob(".shotclip-install.*"))
    checks += 1

print(f"PASS: {checks} signed temporary installer cases (spaces, same-ID migration, distinct backups, wrong IDs, three-path rollback, symlink rejection); no real install or launch")
