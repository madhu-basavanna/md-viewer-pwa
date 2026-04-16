#!/bin/bash
set -e

# ── Configuration ────────────────────────────────────────────
GITHUB_REPOSITORY="madhu-basavanna/md-viewer-pwa"   
REGISTRY="ghcr.io"
IMAGE="$REGISTRY/$GITHUB_REPOSITORY"
# ─────────────────────────────────────────────────────────────

# Ensure a version tag is provided
if [ -z "$1" ]; then
  echo "Usage: ./build-and-push.sh v1.2.3"
  exit 1
fi

VERSION="$1"  # e.g. v1.2.3

# Derive tags (mirrors docker/metadata-action semver behaviour)
FULL_VERSION="${VERSION#v}"                        # 1.2.3
MAJOR_MINOR="${FULL_VERSION%.*}"                   # 1.2

TAG_VERSION="$IMAGE:$FULL_VERSION"
TAG_MAJOR_MINOR="$IMAGE:$MAJOR_MINOR"
TAG_LATEST="$IMAGE:latest"

echo "==> Tags that will be applied:"
echo "    $TAG_VERSION"
echo "    $TAG_MAJOR_MINOR"
echo "    $TAG_LATEST"

# Login to GHCR
echo "==> Logging in to $REGISTRY ..."
echo "$GHCR_PAT" | docker login "$REGISTRY" -u "$GITHUB_USERNAME" --password-stdin

# Build for linux/amd64 (safe default; works from Apple Silicon too)
echo "==> Building image ..."
docker buildx build \
  --platform linux/amd64 \
  -t "$TAG_VERSION" \
  -t "$TAG_MAJOR_MINOR" \
  -t "$TAG_LATEST" \
  --push \
  .

echo "==> Done! Image pushed:"
echo "    $TAG_VERSION"
echo "    $TAG_MAJOR_MINOR"
echo "    $TAG_LATEST"
