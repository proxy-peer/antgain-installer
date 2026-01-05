#!/bin/bash
set -e

# AntGain Linux Installation Script
# Usage: 
#   curl -fsSL https://... | sudo bash
#   curl -fsSL https://... | sudo bash -s 1.0.23
#   curl -fsSL https://... | sudo VERSION=1.0.23 bash

echo "🚀 AntGain Linux Installer"
echo "================================"

# Configuration
R2_BASE_URL="${R2_BASE_URL:-https://pub-a6321dc4515447b698de8db2567150ff.r2.dev}"

# Get version from argument or environment variable
if [ -n "$1" ]; then
    VERSION="$1"
elif [ -z "$VERSION" ]; then
    VERSION=""
fi

# Detect architecture
ARCH=$(uname -m)
if [ "$ARCH" != "x86_64" ]; then
    echo "❌ Error: Only x86_64 architecture is supported"
    exit 1
fi

# Detect distribution
if ! command -v apt-get &> /dev/null; then
    echo "❌ Error: Only Debian/Ubuntu-based distributions are supported"
    exit 1
fi

# Get version
if [ -n "$VERSION" ]; then
    # Use manually specified version
    echo "📦 Using specified version: v$VERSION"
else
    # Get latest version from R2
    echo "📡 Fetching latest version..."
    LATEST_JSON="${R2_BASE_URL}/latest.json"
    
    VERSION_DATA=$(curl -fsSL "$LATEST_JSON" 2>/dev/null || echo "")
    
    if [ -z "$VERSION_DATA" ]; then
        echo "❌ Unable to fetch latest version from R2"
        echo ""
        echo "You can specify version manually to bypass version check:"
        echo "  curl -fsSL ... | sudo bash -s 1.0.23"
        echo ""
        echo "Or check network connection and try again."
        exit 1
    fi
    
    # Extract version number
    VERSION=$(echo "$VERSION_DATA" | grep -o '"version" *: *"[^"]*"' | cut -d'"' -f4)
    
    if [ -z "$VERSION" ]; then
        echo "❌ Error: Unable to parse version information"
        exit 1
    fi
    
    echo "📦 Latest version: v$VERSION"
fi

# Build download URL
DEB_FILENAME="AntGain_${VERSION}_linux-x86_64.deb"
DEB_URL="${R2_BASE_URL}/releases/${VERSION}/${DEB_FILENAME}"

echo "📥 Download URL: $DEB_URL"

# Download
echo "📥 Downloading..."
TMP_DEB="/tmp/antgain_${VERSION}.deb"
if ! curl -fL -o "$TMP_DEB" "$DEB_URL"; then
    echo "❌ Download failed"
    exit 1
fi

# Update package list
echo "🔄 Updating package list..."
apt-get update -qq 2>/dev/null || true

# Install
echo "📦 Installing AntGain..."
if apt-get install -y "$TMP_DEB"; then
    echo "✅ Installation successful!"
    echo ""
    echo "How to run:"
    echo "  • Command line: ant-gain"
    echo "  • App menu: Search for AntGain"
else
    echo "❌ Installation failed"
    echo ""
    echo "Manual installation:"
    echo "  sudo apt install -f"
    rm -f "$TMP_DEB"
    exit 1
fi

# Cleanup
rm -f "$TMP_DEB"

echo ""
echo "🎉 Installation complete!"
