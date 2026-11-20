#!/usr/bin/env bash
#
# publish_to_github.sh — sync a freshly built XCFrameworks/ into this public
# checkout, commit and tag. Push is left to the operator.
#
# Env:
#   BUILD_ROOT   source pod that ran Scripts/build_xcframeworks.sh
#                (contains XCFrameworks/). Required.
#
# Public repo is binary-only; Example demo sources live under Example/.
# An existing tag is never moved — bump the podspec version instead.
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MODULE="$(basename "$ROOT")"
: "${BUILD_ROOT:?Set BUILD_ROOT=/path/to/PrivatePods/$MODULE}"

VERSION="$(ruby -e "require 'cocoapods'; puts Pod::Specification.from_file('$ROOT/$MODULE.podspec').version")"
echo "MODULE=$MODULE VERSION=$VERSION"

if git -C "$ROOT" rev-parse -q --verify "refs/tags/$VERSION" >/dev/null; then
  echo "Tag $VERSION already exists; bump s.version in $MODULE.podspec." >&2
  exit 1
fi

rsync -a --delete "$BUILD_ROOT/XCFrameworks/" "$ROOT/XCFrameworks/"

leaked="$(find "$ROOT" -name '*.swift' ! -path '*/Example/*' ! -path '*/.git/*' 2>/dev/null || true)"
if [[ -n "$leaked" ]]; then
  echo "Refusing to publish: .swift sources detected outside Example/:" >&2
  echo "$leaked" >&2
  exit 1
fi

cd "$ROOT"
git add -A
git commit -m "Release $VERSION (static XCFramework)."
git tag -a "$VERSION" -m "$MODULE $VERSION"
echo "Review, then: git push -u origin HEAD && git push origin $VERSION"
