#!/usr/bin/env python3
"""Validate archive paths and symlinks before ditto extraction; no files are written."""
import posixpath
import stat
import sys
import zipfile

def fail(message):
    raise SystemExit(message)

if len(sys.argv) != 2:
    fail("Expected one release ZIP archive")
with zipfile.ZipFile(sys.argv[1]) as archive:
    entries = archive.infolist()
    if len(entries) > 20000 or sum(item.file_size for item in entries) > 512 * 1024 * 1024:
        fail("Release archive exceeds bounded extraction limits")
    names = set()
    symlinks = set()
    for item in entries:
        name = item.filename.rstrip("/")
        if name in names or "\\" in name or name.startswith("/") or any(part in ("", ".", "..") for part in name.split("/")):
            fail("Release archive contains a duplicate or unsafe path")
        names.add(name)
        if not (name == "ShotClip.app" or name.startswith("ShotClip.app/") or name == "__MACOSX" or name == "__MACOSX/ShotClip.app" or name.startswith("__MACOSX/ShotClip.app/") or name == "__MACOSX/._ShotClip.app"):
            fail("Release ZIP must contain only ShotClip.app and its resource-fork metadata")
        file_type = stat.S_IFMT(item.external_attr >> 16)
        if name == "__MACOSX/ShotClip.app" and (not item.is_dir() or file_type not in (0, stat.S_IFDIR)):
            fail("Release archive metadata app root must be a directory")
        if file_type not in (0, stat.S_IFREG, stat.S_IFDIR, stat.S_IFLNK):
            fail("Release archive contains a special file")
        if file_type == stat.S_IFLNK:
            if not name.startswith("ShotClip.app/") or item.file_size > 4096:
                fail("Release archive has an unsafe symbolic link")
            target = archive.read(item).decode("utf-8")
            resolved = posixpath.normpath(posixpath.join(posixpath.dirname(name), target))
            # Sparkle's framework links use forward-only relative targets. Reject '..'
            # even when lexical normalization looks safe: another link can change its meaning.
            if not target or target.startswith("/") or ".." in target.split("/") or "\\" in target or "\0" in target or not resolved.startswith("ShotClip.app/"):
                fail("Release archive symbolic link escapes the app bundle")
            symlinks.add(name)
    for name in names:
        if any(parent in symlinks for parent in ("/".join(name.split("/")[:i]) for i in range(1, len(name.split("/"))))):
            fail("Release archive writes through a symbolic-link parent")
    if "ShotClip.app/Contents/Info.plist" not in names or "ShotClip.app/Contents/MacOS/shotclip" not in names:
        fail("Release archive is missing ShotClip metadata or executable")
    if archive.testzip() is not None:
        fail("Release archive CRC verification failed")
