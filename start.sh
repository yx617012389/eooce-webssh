#!/bin/bash
export FILE_PATH=${FILE_PATH:-'./webssh'}
export PORT=${PORT:-'8080'}
export USER=${USER:-''}
export PASS=${PASS:-''}

if [ ! -d "${FILE_PATH}" ]; then
    mkdir -p ${FILE_PATH}
fi

ARCH=$(uname -m) && DOWNLOAD_DIR="${FILE_PATH}" && mkdir -p "$DOWNLOAD_DIR" && FILE_INFO=()
if [ "$ARCH" == "arm" ] || [ "$ARCH" == "arm64" ] || [ "$ARCH" == "aarch64" ]; then
    FILE_INFO=("https://github.com/Jrohy/webssh/releases/latest/download/webssh_linux_arm64 webssh")
elif [ "$ARCH" == "amd64" ] || [ "$ARCH" == "x86_64" ] || [ "$ARCH" == "x86" ]; then
    FILE_INFO=("https://github.com/Jrohy/webssh/releases/latest/download/webssh_linux_amd64 webssh")
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi
for entry in "${FILE_INFO[@]}"; do
    URL=$(echo "$entry" | cut -d ' ' -f 1)
    NEW_FILENAME=$(echo "$entry" | cut -d ' ' -f 2)
    FILENAME="$DOWNLOAD_DIR/$NEW_FILENAME"
    if [ -e "$FILENAME" ]; then
        echo -e "\e[1;32m$FILENAME already exists,Skipping download\e[0m"
    else
        curl -L -sS -o "$FILENAME" "$URL"
        echo -e "\e[1;32mDownloading $FILENAME\e[0m"
    fi
done
wait

if [ -e "${FILE_PATH}/webssh" ]; then
  chmod 777 "${FILE_PATH}/webssh"
  if [ -z "${USER}" ] || [ -z "${PASS}" ]; then
    nohup ${FILE_PATH}/webssh -p ${PORT} >/dev/null 2>&1 & 
  else
    nohup ${FILE_PATH}/webssh -p ${PORT} -a ${USER}:${PASS} >/dev/null 2>&1 & 
  fi
  sleep 3
  pgrep -x "webssh" > /dev/null && echo -e "\e[1;32mwebssh is running\e[0m" || { echo -e "\e[1;35mwebssh is not running, restarting...\e[0m"; pkill -x "webssh"; nohup "${FILE_PATH}/webssh" -p ${PORT} -a ${USER}:${PASS} >/dev/null 2>&1 & sleep 2; echo -e "\e[1;32mwebssh restarted\e[0m"; }

fi

IP=$(curl -s --max-time 1 ipv4.ip.sb || curl -s --max-time 1 api.ipify.org || { ipv6=$(curl -s --max-time 1 ipv6.ip.sb); echo "[$ipv6]"; } || echo "未能获取到IP")

echo -e "\e[1;32m访问 http://分配的域名:${PORT} 或 http://${IP}:${PORT}\e[0m"