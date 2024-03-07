#!/bin/bash
kernel=$(uname -r)

if ! command -v jq &> /dev/null; then
    echo -e "\033[33m检测没有JQ正在安装...\033[0m"
    if apt-get update -y > /dev/null && apt-get install jq -y > /dev/null; then
        echo -e "\033[32m安装JQ成功\033[0m"
    else
        echo -e "\033[31m安装JQ失败\033[0m"
        exit 1
    fi
fi

install_CFST() {
    API="https://api.github.com/repos/878088/CFST/releases"
    response=$(curl -s "$API")
    download_urls=$(echo "$response" | jq -r '.[0].assets[] | select((.browser_download_url | contains("linux-libc-dev")) | not) | .browser_download_url')
    arch=$(dpkg --print-architecture)
    if [ "$arch" == "amd64" ]; then
        download_urls=$(echo "$download_urls" | grep "amd64")
    elif [ "$arch" == "arm64" ]; then
        download_urls=$(echo "$download_urls" | grep "arm64")
    else
        echo -e "\033[31m不支持的架构: $arch\033[0m"
        exit 1
    fi
    mkdir -p CFST
    while read -r url; do
        filename=$(basename "$url")
        echo -e "\033[33m正在下载: $filename\033[0m"
        wget -q --show-progress "$url" -P CFST
    done <<< "$download_urls"
    if [ -d "CFST" ]; then
        cd CFST && tar -zxf *.gz && rm -r *.gz
    fi
}

echo -e "\033[37m\n一键安装~BBRv3~脚本\033[0m"
echo ""
echo -e "\033[33m编译者: \033[32m粑屁 Telegram @MJJBPG\033[0m"
echo -e "\033[32m\n——————————————————————\033[0m"
echo -e "\033[33m1. \033[37m 安装~BBRv3 \033[0m"
echo -e "\033[33m2. \033[37m 卸载~BBRv3 \033[0m"
echo -e "\033[32m——————————————————————\033[0m"
echo -e "\033[33m3. \033[37m 安装Linux内核参数 \033[0m"
echo -e "\033[33m4. \033[37m 卸载Linux内核参数 \033[0m"
echo -e "\033[32m——————————————————————\033[0m"
echo -e "\033[33m0. \033[37m 退出 \033[0m"

read -p "选择安装: " choice

case $choice in
    1)
        install_CFST
        ;;
    2)
        uninstall_BBRv3
        ;;
    3)
        install_sysctl
        ;;
    4)
        uninstall_sysctl
        ;;
    0)
        echo -e "\033[33m退出...\033[0m"
        ;;
    *)
        echo -e "\033[31m选择无效\033[0m"
        ;;
esac
