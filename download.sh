#!/bin/bash

{ # this ensures the entire script is downloaded #

lsb_release -d | grep 'Ubuntu' >& /dev/null
[[ $? -ne 0 ]] && { echo "仅支持 WSL Ubuntu 20.04 系统"; exit 1; }

DISTRO=$(lsb_release -c -s)
[[ ${DISTRO} -ne "xenial" ]] && { echo "仅支持 WSL Ubuntu 20.04 系统"; exit 1; }

green="\e[1;32m"
nc="\e[0m"

echo -e "${green}开始下载...${nc}"
cd $HOME
wget -q https://github.com/zoang/wsl-ubuntu/archive/master.tar.gz -O wsl-ubuntu.tar.gz
rm -rf wsl-ubuntu
tar zxf wsl-ubuntu.tar.gz
mv wsl-ubuntu-master wsl-ubuntu
rm -f wsl-ubuntu.tar.gz
echo -e "${green}--下载完毕--${nc}"
echo ""

[ $(id -u) != "0" ] && {
    source ${HOME}/wsl-ubuntu/src/ansi.sh
    ansi --bold --bg-yellow --black "当前账户并非 root，请用 root 账户执行安装脚本（使用命令：sudo -H -s 切换为 root）"
} || {
    bash ./wsl-ubuntu/src/install.sh
}

cd - > /dev/null
} # this ensures the entire script is downloaded #
