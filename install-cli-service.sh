#!/bin/bash
set -e

# AntGain CLI Service Installer
# Usage: 
#   curl -fsSL https://install.antgain.app/cli-service.sh | sudo bash
#   curl -fsSL https://install.antgain.app/cli-service.sh | sudo bash -s YOUR_API_KEY
#   export ANTGAIN_API_KEY=xxx && curl ... | sudo bash

echo "🚀 AntGain CLI Service Installer"
echo "================================"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run as root (use sudo)"
    exit 1
fi

# Check if antgain is installed
if ! command -v antgain &> /dev/null; then
    echo "❌ antgain is not installed"
    echo ""
    echo "Install it first:"
    echo "  curl -fsSL https://raw.githubusercontent.com/proxy-peer/antgain-installer/main/install-cli.sh | bash"
    exit 1
fi

ANTGAIN_BIN="$(command -v antgain)"
echo "✅ Found antgain at: $ANTGAIN_BIN"

# Check if antgain is executable and compatible
# We assume it supports --version or -V or similar, but just checking if it runs is enough.
# If command fails, it might be due to output to stderr, so we silence it.
if ! "$ANTGAIN_BIN" --version >/dev/null 2>&1; then
    echo "⚠️ Warning: '$ANTGAIN_BIN --version' failed or timed out."
    echo "   This might indicate an architecture mismatch (e.g. missing glibc or running x86_64 on arm)."
    echo "   Continuing, but the service might fail to start."
    # We don't exit here because some binaries might not have --version or exit 1 on unknown flag
else
    echo "✅ Binary verified executable."
fi


# Get API key from: 1. argument, 2. environment variable, 3. interactive input
if [ -n "$1" ]; then
    ANTGAIN_API_KEY="$1"
    echo "📝 Using API Key from argument"
elif [ -n "$ANTGAIN_API_KEY" ]; then
    echo "📝 Using API Key from environment variable"
else
    echo "📝 Please enter your API Key:"
    read -r ANTGAIN_API_KEY
fi

if [ -z "$ANTGAIN_API_KEY" ]; then
    echo "❌ API Key is required"
    echo ""
    echo "You can provide it in three ways:"
    echo "  1. As argument:     curl ... | sudo bash -s YOUR_API_KEY"
    echo "  2. As environment:  export ANTGAIN_API_KEY=xxx && curl ... | sudo bash"
    echo "  3. Interactive:     curl ... | sudo bash  (will prompt)"
    exit 1
fi

echo "📦 Configuring service..."

# Detect OS
OS="$(uname -s)"
SERVICE_NAME="app.antgain.cli"

if [ "$OS" = "Darwin" ]; then
    # macOS LaunchDaemon
    PLIST_PATH="/Library/LaunchDaemons/${SERVICE_NAME}.plist"
    
    echo "🍎 Detected macOS. Creating LaunchDaemon at $PLIST_PATH"
    
    cat > "$PLIST_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${SERVICE_NAME}</string>
    <key>ProgramArguments</key>
    <array>
        <string>${ANTGAIN_BIN}</string>
    </array>
    <key>EnvironmentVariables</key>
    <dict>
        <key>ANTGAIN_API_KEY</key>
        <string>${ANTGAIN_API_KEY}</string>
        <key>LOG_LEVEL</key>
        <string>info</string>
    </dict>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/var/log/antgain.log</string>
    <key>StandardErrorPath</key>
    <string>/var/log/antgain.error.log</string>
</dict>
</plist>
EOF

    # Set permissions
    chown root:wheel "$PLIST_PATH"
    chmod 644 "$PLIST_PATH"

    # Load service
    echo "🔄 Loading service..."
    # Unload first just in case
    launchctl unload "$PLIST_PATH" 2>/dev/null || true
    launchctl load -w "$PLIST_PATH"

    echo "✅ Service installed and started!"
    echo ""
    echo "Status:"
    sudo launchctl list | grep antgain || echo "Service running (PID might vary)"

elif [ "$OS" = "Linux" ]; then
    # Linux Systemd
    echo "🐧 Detected Linux. Creating systemd service..."

    # Create service file
    cat > /etc/systemd/system/antgain.service << EOF
[Unit]
Description=AntGain CLI Node
After=network.target

[Service]
Type=simple
User=nobody
Environment="ANTGAIN_API_KEY=${ANTGAIN_API_KEY}"
Environment="LOG_LEVEL=info"
ExecStart=${ANTGAIN_BIN}
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

    # Reload systemd
    echo "🔄 Reloading systemd..."
    systemctl daemon-reload

    # Enable service
    echo "✅ Enabling service..."
    systemctl enable antgain

    # Start service
    echo "🚀 Starting service..."
    systemctl start antgain

    # Wait a moment for service to start
    sleep 2

    # Show status
    echo ""
    echo "✅ Installation complete!"
    echo ""
    echo "Service status:"
    systemctl status antgain --no-pager -l || true

else
    echo "❌ Unsupported OS for service installation: $OS"
    exit 1
fi

echo ""
echo "Useful commands:"
if [ "$OS" = "Darwin" ]; then
    echo "  sudo launchctl load -w $PLIST_PATH    # Start/Enable"
    echo "  sudo launchctl unload -w $PLIST_PATH  # Stop/Disable"
    echo "  tail -f /var/log/antgain.log          # View logs"
else
    echo "  sudo systemctl status antgain   # Check status"
    echo "  sudo systemctl stop antgain     # Stop service"
    echo "  sudo systemctl start antgain    # Start service"
    echo "  sudo systemctl restart antgain  # Restart service"
    echo "  sudo journalctl -u antgain -f   # View logs"
fi
