#!/bin/bash
set -euo pipefail

PACKAGE_NAME=$1
VERSION=$2
ARCH=$3
UPSTREAM_REPO=$4

source package.env

echo "Building $PACKAGE_NAME from source (version $VERSION) for $ARCH"

# Create Debian package structure
BUILD_DIR="build_${PACKAGE_NAME}_${VERSION}_${ARCH}"
mkdir -p "$BUILD_DIR/DEBIAN"
mkdir -p "$BUILD_DIR/usr/bin"
mkdir -p "$BUILD_DIR/usr/share/doc/$PACKAGE_NAME"
mkdir -p output

# ----- TEMPLATE SECTION: Customize how to build from source -----
# Clone the repository
git clone --depth 1 --branch "v${VERSION}" "https://github.com/${UPSTREAM_REPO}.git" src_dir

# Enter directory and build
pushd src_dir
  # Replace with actual build commands (e.g., `make`, `cargo build --release`, `go build`)
  echo "Simulating build process..."
  
  # Copy the compiled binary to the build directory
  # cp target/release/$PACKAGE_NAME "../$BUILD_DIR/usr/bin/"
popd

# Fallback fake binary (remove this when implementing your actual package!)
echo "#!/bin/sh" > "$BUILD_DIR/usr/bin/$PACKAGE_NAME"
echo "echo Built from source: $PACKAGE_NAME version $VERSION" >> "$BUILD_DIR/usr/bin/$PACKAGE_NAME"
chmod +x "$BUILD_DIR/usr/bin/$PACKAGE_NAME"
# ----------------------------------------------------------------

# Create control file
cat <<EOF > "$BUILD_DIR/DEBIAN/control"
Package: $PACKAGE_NAME
Version: $VERSION
Architecture: $ARCH
Maintainer: $MAINTAINER
Description: $DESCRIPTION
Homepage: $HOMEPAGE
EOF

# Create copyright file
cat <<EOF > "$BUILD_DIR/usr/share/doc/$PACKAGE_NAME/copyright"
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: $PACKAGE_NAME
Source: $HOMEPAGE
License: $LICENSE
EOF

# Build package
dpkg-deb --build "$BUILD_DIR" "output/${PACKAGE_NAME}_${VERSION}_${ARCH}.deb"

echo "Package built at output/${PACKAGE_NAME}_${VERSION}_${ARCH}.deb"
