#!/bin/bash
set -e

# AntGain CLI DEB Installation Script
# 用于 Debian/Ubuntu 系统安装 CLI 命令行工具 (deb 包安装方式)
# Usage: 
#   curl -fsSL https://raw.githubusercontent.com/proxy-peer/antgain-installer/main/install-cli-deb.sh | sudo bash
#   curl -fsSL https://raw.githubusercontent.com/proxy-peer/antgain-installer/main/install-cli-deb.sh | sudo bash -s 1.0.24

echo "🚀 AntGain CLI DEB Installer"
echo "================================"

# 检查 root 权限
if [ "$EUID" -ne 0 ]; then 
    echo "❌ 请使用 root 权限运行 (使用 sudo)"
    exit 1
fi

# Configuration
R2_BASE_URL="${R2_BASE_URL:-https://pub-a6321dc4515447b698de8db2567150ff.r2.dev}"

# 获取版本号：1. 命令行参数, 2. 环境变量, 3. 自动获取最新版本
if [ -n "$1" ]; then
    VERSION="$1"
elif [ -z "$VERSION" ]; then
    VERSION=""
fi

# 检测系统架构
ARCH=$(uname -m)
case "$ARCH" in
    x86_64|amd64)
        ARCH_TYPE="amd64"
        ;;
    aarch64|arm64)
        ARCH_TYPE="arm64"
        ;;
    *)
        echo "❌ 错误: 不支持的架构 $ARCH (仅支持 x86_64/amd64 和 arm64)"
        exit 1
        ;;
esac

echo "📋 系统信息:"
echo "  架构: $ARCH_TYPE"

# 检测发行版
if ! command -v apt-get &> /dev/null; then
    echo "❌ 错误: 仅支持 Debian/Ubuntu 等基于 apt 的系统"
    echo ""
    echo "如果您使用其他 Linux 发行版，请使用通用安装脚本:"
    echo "  curl -fsSL https://raw.githubusercontent.com/proxy-peer/antgain-installer/main/install-cli.sh | bash"
    exit 1
fi

# 获取版本号
if [ -n "$VERSION" ]; then
    echo "📦 使用指定版本: v$VERSION"
else
    # 从 R2 获取最新版本
    echo "📡 正在获取最新 CLI 版本..."
    LATEST_JSON="${R2_BASE_URL}/cli/latest.json"
    
    VERSION_DATA=$(curl -fsSL "$LATEST_JSON" 2>/dev/null || echo "")
    
    if [ -z "$VERSION_DATA" ]; then
        echo "❌ 无法获取最新版本信息"
        echo ""
        echo "您可以手动指定版本号绕过版本检查:"
        echo "  curl -fsSL ... | sudo bash -s 1.0.24"
        echo ""
        echo "或检查网络连接后重试。"
        exit 1
    fi
    
    # 提取版本号
    VERSION=$(echo "$VERSION_DATA" | grep -o '"version":"[^"]*' | head -1 | cut -d'"' -f4)
    
    if [ -z "$VERSION" ]; then
        echo "❌ 错误: 无法解析版本信息"
        exit 1
    fi
    
    echo "📦 最新版本: v$VERSION"
fi

# 构建下载 URL
DEB_FILENAME="antgain-cli_${VERSION}-1_${ARCH_TYPE}.deb"
DEB_URL="${R2_BASE_URL}/cli/releases/${VERSION}/${DEB_FILENAME}"

echo "📥 下载链接: $DEB_URL"

# 下载
echo "📥 正在下载..."
TMP_DEB="/tmp/antgain-cli_${VERSION}_${ARCH_TYPE}.deb"
if ! curl -fL -o "$TMP_DEB" "$DEB_URL"; then
    echo "❌ 下载失败"
    echo ""
    echo "请检查版本号是否正确，或尝试使用通用安装脚本:"
    echo "  curl -fsSL https://raw.githubusercontent.com/proxy-peer/antgain-installer/main/install-cli.sh | bash"
    exit 1
fi

# 更新包列表
echo "🔄 正在更新包列表..."
apt-get update -qq 2>/dev/null || true

# 安装
echo "📦 正在安装 AntGain CLI..."
if apt-get install -y "$TMP_DEB"; then
    echo "✅ 安装成功!"
    echo ""
    echo "使用方法:"
    echo "  antgain --api-key YOUR_API_KEY"
    echo ""
    echo "查看帮助:"
    echo "  antgain --help"
else
    echo "❌ 安装失败"
    echo ""
    echo "手动修复依赖:"
    echo "  sudo apt install -f"
    rm -f "$TMP_DEB"
    exit 1
fi

# 清理
rm -f "$TMP_DEB"

echo ""
echo "🎉 安装完成!"
echo ""
echo "获取 API Key: https://antgain.app/dashboard/settings"
echo ""
echo "作为系统服务运行:"
echo "  curl -fsSL https://raw.githubusercontent.com/proxy-peer/antgain-installer/main/install-cli-service.sh | sudo bash"
