#!/usr/bin/env bash
# bump - update version, commit, and tag

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: ./bump <new-version>"
  exit 1
fi

version="$1"

# Update VERSION line in Makefile
sed -i.bak -E "s/^(VERSION \?\= ).*/\1$version/" Makefile
rm -f Makefile.bak

# Commit + tag
git add Makefile
git commit -m "Release v$version"
git tag "v$version"

echo "✅ Bumped to $version and created git tag v$version"
echo "Now push with: git push origin main --tags"

