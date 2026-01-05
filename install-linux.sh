#!/bin/bash
set -e

# AntGain Linux Installation Script
# Usage: 
#   curl -fsSL https://... | sudo bash
#   curl -fsSL https://... | sudo bash -s 1.0.23
#   curl -fsSL https://... | sudo VERSION=1.0.23 bash

echo "🚀 AntGain Linux Installer"
echo "================================"

# Configuration - modify for your repository
GITHUB_USER="${GITHUB_USER:-proxy-peer}"
GITHUB_REPO="${GITHUB_REPO:-antgain}"

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
    # Try to get latest version from GitHub API
    echo "📡 Fetching latest version..."
    GITHUB_API="https://api.github.com/repos/${GITHUB_USER}/${GITHUB_REPO}/releases/latest"
    
    # Note: GitHub private repository releases can be set to public
    RELEASE_DATA=$(curl -fsSL "$GITHUB_API" 2>/dev/null || echo "")
    
    if [ -z "$RELEASE_DATA" ]; then
        echo "❌ Unable to access release information"
        echo ""
        echo "For private repositories, specify version:"
        echo "  curl -fsSL ... | sudo bash -s 1.0.23"
        echo "  curl -fsSL ... | sudo VERSION=1.0.23 bash"
        echo ""
        echo "Or download manually from:"
        echo "  https://github.com/${GITHUB_USER}/${GITHUB_REPO}/releases"
        exit 1
    fi
    
    # Extract version number
    VERSION=$(echo "$RELEASE_DATA" | grep -o '"tag_name": *"[^"]*"' | head -1 | cut -d'"' -f4 | sed 's/^v//')
    
    if [ -z "$VERSION" ]; then
        echo "❌ Error: Unable to get version information"
        exit 1
    fi
    
    echo "📦 Latest version: v$VERSION"
fi

# Build download URL
DEB_FILENAME="AntGain_${VERSION}_linux-x86_64.deb"
DEB_URL="https://github.com/${GITHUB_USER}/${GITHUB_REPO}/releases/download/v${VERSION}/${DEB_FILENAME}"

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
