#!/bin/bash

set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo "Usage: $0 /path/to/Nudge.app [output-directory]" >&2
    exit 64
fi

app_path=$1
output_directory=${2:-dist}
info_plist="$app_path/Contents/Info.plist"

if [[ ! -d "$app_path" || ! -f "$info_plist" ]]; then
    echo "Nudge app not found at: $app_path" >&2
    exit 66
fi

version=$(
    /usr/libexec/PlistBuddy \
        -c "Print :CFBundleShortVersionString" \
        "$info_plist"
)

archive_path="$output_directory/Nudge-$version.zip"

if [[ -e "$archive_path" ]]; then
    echo "Archive already exists: $archive_path" >&2
    exit 73
fi

codesign --verify --deep --strict --verbose=2 "$app_path"
spctl --assess --type execute --verbose=2 "$app_path"
xcrun stapler validate "$app_path"

mkdir -p "$output_directory"
ditto -c -k --sequesterRsrc --keepParent \
    "$app_path" \
    "$archive_path"

echo "Created $archive_path"
