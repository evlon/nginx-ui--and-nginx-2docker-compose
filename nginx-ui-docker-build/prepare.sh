#!/bin/bash
set -e

# --- 配置 ---
DOWNLOADS_DIR="downloads"
NGINX_UI_REPO="0xJacky/nginx-ui"
NGINX_UI_ARCH="linux-64" # 目标架构，如果您的运行环境是 arm64，请改为 arm64

echo "--- 1. 准备下载目录 ---"
mkdir -p "$DOWNLOADS_DIR"

# 检查 jq 是否安装
if ! command -v jq &> /dev/null
then
    echo "⚠️ 警告: jq (JSON处理器) 未安装，正在尝试安装..."
    # 尝试安装 jq (假设在 Debian/Ubuntu 环境)
    sudo apt-get update && sudo apt-get install -y jq
    if [ $? -ne 0 ]; then
        echo "致命错误: 无法安装 jq。请手动安装 jq 或修改脚本。"
        exit 1
    fi
fi

echo "--- 2. 查找 Nginx-UI 最新版本和文件名 ---"
RESPONSE=$(curl -s "https://api.github.com/repos/${NGINX_UI_REPO}/releases/latest")

NGINX_UI_VERSION=$(echo "$RESPONSE" | jq -r ".tag_name")

# 关键优化：使用两步过滤确保排除 .digest 文件
NGINX_UI_FILENAME=$(echo "$RESPONSE" | \
    jq -r ".assets[] | 
        # 1. 筛选包含 linux-64 的文件
        select(.name | contains(\"nginx-ui-${NGINX_UI_ARCH}\")) |
        # 2. 排除以 .digest 结尾的文件
        select(.name | endswith(\".digest\") | not) |
        .name")

if [ -z "$NGINX_UI_VERSION" ] || [ -z "$NGINX_UI_FILENAME" ]; then
    echo "❌ 错误：未能获取 Nginx-UI 最新版本或文件名。"
    echo "请检查 GitHub API 访问是否受限，或架构 (${NGINX_UI_ARCH}) 是否有对应文件。"
    exit 1
fi

echo "✅ 找到 Nginx-UI 最新版本: ${NGINX_UI_VERSION}"
echo "✅ 找到对应文件名: ${NGINX_UI_FILENAME}"

# 构造下载链接
NGINX_UI_URL="https://github.com/${NGINX_UI_REPO}/releases/download/${NGINX_UI_VERSION}/${NGINX_UI_FILENAME}"
DOWNLOAD_PATH="${DOWNLOADS_DIR}/${NGINX_UI_FILENAME}"

echo "--- 3. 下载 Nginx-UI 最新版本 ---"
# 如果文件已经存在，则跳过下载
if [ -f "$DOWNLOAD_PATH" ]; then
    echo "文件已存在 ($DOWNLOAD_PATH)，跳过下载。"
else
    echo "正在从 ${NGINX_UI_URL} 下载..."
    #wget "$NGINX_UI_URL" -O "$DOWNLOAD_PATH"
    curl -L -o "$DOWNLOAD_PATH" "$NGINX_UI_URL"
fi

if [ $? -ne 0 ]; then
    echo "❌ 致命错误: WGET 下载失败。请检查 URL 或网络连接。"
    exit 1
fi

echo "--- 4. 打印当前准备好的文件清单 ---"
ls -lh "$DOWNLOADS_DIR"

echo "✅ 准备工作完成，可以开始 Docker 构建了。"