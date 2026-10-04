#!/bin/bash
# Temporary synthetic resources only; no builds, signing, installs or user data.
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/release-common.sh
fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/shotclip-resource-test.XXXXXX")"
trap 'rm -rf "$fixture_root"' EXIT
count=0

make_bundle() {
    local bundle="$1" layout="$2" resource_dir="$1" language table
    if [[ "$layout" == native ]]; then resource_dir="$bundle/Contents/Resources"; fi
    for language in en ko; do
        mkdir -p "$resource_dir/$language.lproj"
        for table in Localizable Updates; do
            printf '"fixture" = "Synthetic resource";\n' > "$resource_dir/$language.lproj/$table.strings"
        done
    done
}

accept() {
    local bundle="$1" expected="$2" actual
    actual="$(release_resource_directory "$bundle")" || release_fail "FAIL: valid fixture rejected: $bundle"
    [[ "$actual" == "$expected" ]] || release_fail "FAIL: wrong resource directory: $actual"
    count=$((count + 1))
}

reject() {
    local bundle="$1" actual
    if actual="$(release_resource_directory "$bundle")"; then
        release_fail "FAIL: unsafe/incomplete fixture accepted: $bundle ($actual)"
    fi
    [[ -z "$actual" ]] || release_fail "FAIL: rejected fixture emitted a resource directory: $bundle"
    count=$((count + 1))
}

for layout in flat native; do
    bundle="$fixture_root/$layout.bundle"
    make_bundle "$bundle" "$layout"
    resource_dir="$bundle"
    if [[ "$layout" == native ]]; then resource_dir="$bundle/Contents/Resources"; fi
    accept "$bundle" "$resource_dir"

    for language in en ko; do
        for table_name in Localizable Updates; do
        table="$resource_dir/$language.lproj/$table_name.strings"
        mv "$table" "$resource_dir/saved.strings"
        reject "$bundle"
        ln -s ../saved.strings "$table"
        reject "$bundle"
        rm "$table"
        mkdir "$table"
        reject "$bundle"
        rmdir "$table"
        mv "$resource_dir/saved.strings" "$table"
        done
    done

    mv "$resource_dir/en.lproj" "$resource_dir/saved.lproj"
    ln -s saved.lproj "$resource_dir/en.lproj"
    reject "$bundle"
    rm "$resource_dir/en.lproj"
    mv "$resource_dir/saved.lproj" "$resource_dir/en.lproj"
    ln -s "$bundle" "$fixture_root/$layout-linked.bundle"
    reject "$fixture_root/$layout-linked.bundle"
done

native="$fixture_root/native.bundle"
mv "$native/Contents/Resources" "$native/Contents/saved-resources"
ln -s saved-resources "$native/Contents/Resources"
reject "$native"
rm "$native/Contents/Resources"
mv "$native/Contents/saved-resources" "$native/Contents/Resources"
mv "$native/Contents" "$native/saved-contents"
ln -s saved-contents "$native/Contents"
reject "$native"
rm "$native/Contents"
mv "$native/saved-contents" "$native/Contents"

# Once native bundle structure exists, incomplete resources must not fall back.
mixed="$fixture_root/incomplete-native.bundle"
make_bundle "$mixed" flat
mkdir -p "$mixed/Contents/Resources/en.lproj"
reject "$mixed"
reject "$fixture_root/missing.bundle"

printf 'PASS: %s resource layout checks (native/flat, missing languages/tables, both Localizable/Updates nonregular tables, symlink rejection); temp fixtures only\n' "$count"
