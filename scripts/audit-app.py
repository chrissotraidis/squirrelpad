#!/usr/bin/env python3
"""Audit a local developer app; passing is not distribution clearance."""
import argparse
import hashlib
import json
import plistlib
import re
import subprocess
from pathlib import Path


def command(*args):
    return subprocess.run(args, check=True, capture_output=True, text=True).stdout


def digest(data):
    return hashlib.sha256(data).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("app", type=Path)
    parser.add_argument("--sdk", required=True, choices=("iphoneos", "iphonesimulator"))
    parser.add_argument("--source", required=True, type=Path, help="Pinned Conker checkout")
    parser.add_argument("--output", required=True, type=Path, help="Private JSON report")
    args = parser.parse_args()
    root = Path(__file__).resolve().parent.parent
    failures = []
    pins = json.loads((root / "sources.lock.json").read_text())
    revisions = {".": command("git", "-C", str(args.source), "rev-parse", "HEAD").strip()}
    expected_revisions = {".": pins["upstream"]["commit"], **pins["gitlinks"]}
    for path, expected in expected_revisions.items():
        if path != ".":
            revisions[path] = command("git", "-C", str(args.source / path), "rev-parse", "HEAD").strip()
        if revisions[path] != expected:
            failures.append(f"Source revision mismatch: {path}")

    cmake = (root / "CMakeLists.txt").read_text()
    expected_notices = {
        name + ".txt": (args.source / path).read_bytes()
        for name, path in re.findall(r'"([^"|]+)\|([^"|]+)"', cmake)
    }
    for path in (root / "Support/Notices").glob("*.txt"):
        expected_notices[path.name] = path.read_bytes()
    bundled_notices = {path.name: path.read_bytes() for path in (args.app / "ThirdPartyNotices").glob("*.txt")}
    if bundled_notices.keys() != expected_notices.keys():
        failures.append("Notice file set differs from source manifest")
    for name, data in expected_notices.items():
        if bundled_notices.get(name) != data:
            failures.append(f"Notice missing or bytes differ: {name}")

    info = plistlib.loads((args.app / "Info.plist").read_bytes())
    if info.get("CFBundleIdentifier") != "com.chrissotraidis.squirrelpad":
        failures.append("Unexpected bundle identifier")
    executable = args.app / info["CFBundleExecutable"]
    architecture = command("xcrun", "lipo", "-archs", str(executable)).strip()
    if architecture != "arm64":
        failures.append("Expected ARM64 executable only")
    build = command("xcrun", "vtool", "-show-build", str(executable))
    platform = re.search(r"platform\s+(\w+)", build).group(1)
    expected_platform = "IOS" if args.sdk == "iphoneos" else "IOSSIMULATOR"
    if platform != expected_platform:
        failures.append("Executable platform does not match requested SDK")
    symbols = command("xcrun", "nm", "-a", str(executable))
    forbidden_symbols = [name for name in ("LiveGenerator", "ShimFunction", "sljit", "SimulatorInputProbe") if name in symbols]
    if forbidden_symbols:
        failures.append("Excluded runtime/probe symbols found")

    inventory, private_names, private_content, symlinks = [], [], [], []
    for path in sorted(args.app.rglob("*")):
        relative = path.relative_to(args.app).as_posix()
        if path.is_symlink():
            symlinks.append(relative)
            continue
        if not path.is_file():
            continue
        data = path.read_bytes()
        inventory.append({"path": relative, "bytes": len(data), "sha256": digest(data)})
        if (path.suffix.lower() in (".z64", ".n64", ".v64", ".sav", ".eep", ".pem", ".p12", ".key")
                or "saves" in path.parts or "RecompiledFuncs" in path.parts
                or "conker.n64.us.1.0.bin" in path.name
                or (len(data) == pins["rom"]["size"] and hashlib.sha1(data).hexdigest() == pins["rom"]["sha1"])):
            private_names.append(relative)
        # Report file names only, never matched private bytes.
        if any(marker in data for marker in (b"/Users/", b"/home/", b"-----BEGIN PRIVATE KEY-----", b"-----BEGIN RSA PRIVATE KEY-----")):
            private_content.append(relative)
    if private_names or private_content or symlinks:
        failures.append("Private filename/content or symlink requires review")
    report = {
        "sdk": args.sdk, "architecture": architecture, "platform": platform,
        "bundleID": info.get("CFBundleIdentifier"), "executableSHA256": digest(executable.read_bytes()),
        "sourceRevisions": revisions, "noticeCount": len(bundled_notices),
        "excludedSymbolMatches": forbidden_symbols, "privateFilenameMatches": private_names,
        "privateContentMatches": private_content, "symlinks": symlinks,
        "files": inventory, "failures": failures,
        "scope": "Local developer bundle audit only. ROM-derived native code remains. No signing, gameplay or distribution clearance claim.",
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + "\n")
    print(f"{args.sdk}: {'FAIL' if failures else 'PASS'}; {len(inventory)} files, {len(bundled_notices)} notices; {report['executableSHA256']}")
    for failure in failures:
        print(f"  {failure}")
    return bool(failures)


if __name__ == "__main__":
    raise SystemExit(main())
