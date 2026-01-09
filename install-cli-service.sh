#!/bin/bash
set -e

# AntGain CLI Systemd Service Installer
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

echo "📦 Creating systemd service..."

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
ExecStart=/usr/local/bin/antgain
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
echo ""
echo "Useful commands:"
echo "  sudo systemctl status antgain   # Check status"
echo "  sudo systemctl stop antgain     # Stop service"
echo "  sudo systemctl start antgain    # Start service"
echo "  sudo systemctl restart antgain  # Restart service"
echo "  sudo journalctl -u antgain -f   # View logs"
