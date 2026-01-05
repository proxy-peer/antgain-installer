#!/bin/bash
set -e

# AntGain CLI Installation Script
# Usage: 
#   curl -fsSL https://install.antgain.app/cli.sh | bash
#   curl -fsSL https://install.antgain.app/cli.sh | bash -s 1.0.0

echo "🚀 AntGain CLI Installer"
echo "================================"

# Configuration
R2_BASE_URL="${R2_BASE_URL:-https://pub-a6321dc4515447b698de8db2567150ff.r2.dev}"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"

# Detect OS and Architecture
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
    Linux*)
        OS_TYPE="linux"
        ;;
    Darwin*)
        OS_TYPE="darwin"
        ;;
    *)
        echo "❌ Unsupported OS: $OS"
        exit 1
        ;;
esac

case "$ARCH" in
    x86_64|amd64)
        ARCH_TYPE="amd64"
        ;;
    aarch64|arm64)
        ARCH_TYPE="arm64"
        ;;
    *)
        echo "❌ Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

echo "📋 System Info:"
echo "  OS: $OS_TYPE"
echo "  Arch: $ARCH_TYPE"

# Get version from argument or environment variable
if [ -n "$1" ]; then
    VERSION="$1"
elif [ -z "$VERSION" ]; then
    # Fetch latest version
    echo "📡 Fetching latest CLI version..."
    LATEST_JSON="${R2_BASE_URL}/cli/latest.json"
    
    VERSION_DATA=$(curl -fsSL "$LATEST_JSON" 2>/dev/null || echo "")
    
    if [ -z "$VERSION_DATA" ]; then
        echo "❌ Failed to fetch version info"
        echo ""
        echo "You can install manually from:"
        echo "  https://github.com/proxy-peer/antgain/releases"
        exit 1
    fi
    
    VERSION=$(echo "$VERSION_DATA" | grep -o '"version":"[^"]*' | head -1 | cut -d'"' -f4)
    
    if [ -z "$VERSION" ]; then
        echo "❌ Failed to parse version from response"
        exit 1
    fi
fi

echo "📦 Installing version: $VERSION"

# Download URL
FILENAME="antgain-${OS_TYPE}-${ARCH_TYPE}.tar.gz"
DOWNLOAD_URL="${R2_BASE_URL}/cli/releases/${VERSION}/${FILENAME}"

echo "📥 Downloading from: $DOWNLOAD_URL"

# Download
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

if ! curl -fL -o "$FILENAME" "$DOWNLOAD_URL"; then
    echo "❌ Download failed"
    rm -rf "$TMP_DIR"
    exit 1
fi

# Extract
echo "📦 Extracting..."
tar xzf "$FILENAME"

# Install
echo "📦 Installing to $INSTALL_DIR..."
if [ -w "$INSTALL_DIR" ]; then
    mv antgain "$INSTALL_DIR/antgain"
    chmod +x "$INSTALL_DIR/antgain"
else
    sudo mv antgain "$INSTALL_DIR/antgain"
    sudo chmod +x "$INSTALL_DIR/antgain"
fi

# Cleanup
cd -
rm -rf "$TMP_DIR"

echo "✅ Installation successful!"
echo ""
echo "Usage:"
echo "  antgain --api-key YOUR_API_KEY"
echo ""
echo "Get your API key from: https://antgain.app/dashboard/settings"
echo ""
echo "Run as systemd service:"
echo "  sudo curl -fsSL https://raw.githubusercontent.com/proxy-peer/antgain-installer/main/install-cli.sh | bash"
