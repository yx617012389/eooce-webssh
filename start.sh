#!/bin/bash
export FILE_PATH=${FILE_PATH:-'./webssh'}     # 安装目录
export PORT=${PORT:-''}                       # web端口，留空默认8888
export USER=${USER:-''}                       # 登录用户名，可为空
export PASS=${PASS:-''}                       # 登录密码，可为空

mkdir -p "${FILE_PATH}"
ARCH=$(uname -m)
DOWNLOAD_DIR="${FILE_PATH}"

# 根据架构设置下载URL和文件名
if [ "$ARCH" = "arm64" ] || [ "$ARCH" = "aarch64" ]; then
    ARCH="arm64"
elif [ "$ARCH" = "amd64" ] || [ "$ARCH" = "x86_64" ]; then
    ARCH="amd64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

BASE_URL="https://github.com/eooce/webssh/releases/download/webssh"
FILE_URL="${BASE_URL}/webssh_linux_${ARCH}"
FILE_NAME="webssh"
FILENAME="$DOWNLOAD_DIR/$FILE_NAME"

if [ -e "$FILENAME" ]; then
    echo -e "\e[1;32m$FILENAME already exists, Skipping download\e[0m"
else
    echo -e "\e[1;32mDownloading $FILE_NAME for $ARCH architecture...\e[0m"
    curl -L -sS -o "$FILENAME" "$FILE_URL" || { echo -e "\e[1;31mFailed to download $FILE_URL\e[0m"; exit 1; }
fi

wait

# 启动 webssh
if [ -e "${FILE_PATH}/webssh" ]; then
    chmod +x "${FILE_PATH}/webssh"
    
    echo -e "\e[1;34mStarting webssh...\e[0m"
    
    # 判断启动参数组合
    if [ -n "${PORT}" ] && [ -n "${USER}" ] && [ -n "${PASS}" ]; then
        nohup "${FILE_PATH}/webssh" -p "${PORT}" -a "${USER}:${PASS}" >/dev/null 2>&1 &
    elif [ -n "${PORT}" ]; then
        nohup "${FILE_PATH}/webssh" -p "${PORT}" >/dev/null 2>&1 &
    elif [ -n "${USER}" ] && [ -n "${PASS}" ]; then
        nohup "${FILE_PATH}/webssh" -a "${USER}:${PASS}" >/dev/null 2>&1 &
    else
        nohup "${FILE_PATH}/webssh" >/dev/null 2>&1 &
    fi

    sleep 6
    if pgrep -x "webssh" > /dev/null; then
        echo -e "\e[1;32mwebssh is running\e[0m"
    else 
        echo -e "\e[1;35mwebssh is not running, restarting...\e[0m"
        pkill -x "webssh"
        if [ -n "${PORT}" ] && [ -n "${USER}" ] && [ -n "${PASS}" ]; then
            nohup "${FILE_PATH}/webssh" -p "${PORT}" -a "${USER}:${PASS}" >/dev/null 2>&1 &
        elif [ -n "${PORT}" ]; then
            nohup "${FILE_PATH}/webssh" -p "${PORT}" >/dev/null 2>&1 &
        elif [ -n "${USER}" ] && [ -n "${PASS}" ]; then
            nohup "${FILE_PATH}/webssh" -a "${USER}:${PASS}" >/dev/null 2>&1 &
        else
            nohup "${FILE_PATH}/webssh" >/dev/null 2>&1 &
        fi
        sleep 3
        echo -e "\e[1;32mwebssh restarted\e[0m"
    fi
else
    echo -e "\e[1;31mwebssh not found in ${FILE_PATH}\e[0m"
fi

# 获取IP地址
IP=$(curl -s --max-time 1 ipv4.ip.sb || curl -s --max-time 1 api.ipify.org || { 
    ipv6=$(curl -s --max-time 1 ipv6.ip.sb); echo "[$ipv6]"; 
} || echo "未能获取到IP")

# 显示访问信息（只有在PORT被设置时显示端口）
if [ -n "${PORT}" ]; then
    echo -e "\e[1;32mwebssh 已启动，访问 http://分配的域名 或 http://${IP}:${PORT}\e[0m"
else
    echo -e "\e[1;32mwebssh 已启动，访问 http://${IP}:8888 或分配域名\e[0m"
fi
