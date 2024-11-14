#!/bin/bash

# 检查是否以 root 用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以 root 用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到 root 用户，然后再次运行此脚本。"
    exit 1
fi

# 安装和配置 Nodepay 函数
function setup_Nodepay() {
    # 检查 Nodepay 目录是否存在，如果存在则删除
    if [ -d "Nodepay" ]; then
        echo "检测到 Nodepay 目录已存在，正在删除..."
        rm -rf Nodepay
        echo "Nodepay 目录已删除。"
    fi

    # 安装 Python 3.11
    sudo apt update
    sudo apt install -y software-properties-common
    sudo add-apt-repository ppa:deadsnakes/ppa -y
    sudo apt-get install -y python3-apt
    # 添加 python3.11-venv 的安装
    sudo apt install -y python3.11 python3.11-venv python3.11-dev python3-pip
    echo "Python 3.11 和 pip 安装完成。"

    echo "正在从 GitHub 克隆 Nodepay 仓库..."
    git clone https://github.com/sdohuajia/Nodepay.git Nodepay
    if [ ! -d "Nodepay" ]; then
        echo "克隆失败，请检查网络连接或仓库地址。"
        exit 1
    fi

    cd "Nodepay" || { echo "无法进入 Nodepay 目录"; exit 1; }

    echo "正在安装所需的 Python 包..."
    if [ ! -f requirements.txt ]; then
        echo "未找到 requirements.txt 文件，无法安装依赖。"
        exit 1
    fi
    
    python3.11 -m pip install -r requirements.txt

    # 手动安装 httpx 和 aiohttp
    python3.11 -m pip install httpx 
    python3 -m pip install aiohttp

    # 获取用户ID并写入 np_tokens.txt
    read -p "请输入您的 np_tokens: " user_id
    uid_file="/root/Nodepay/np_tokens.txt"  # uid 文件路径

    # 将 userId 写入文件
    echo "$user_id" > "$uid_file"
    echo "userId 已添加到 $uid_file."

    # 安装 pm2
    sudo apt install -y nodejs npm
    sudo npm install -g pm2

    echo "正在使用 pm2 启动 main.py..."
    pm2 start main.py --name Nodepay
    echo "使用 'pm2 logs Nodepay' 命令来查看日志。"
    echo "使用 'pm2 stop Nodepay' 命令来停止服务。"
    echo "使用 'pm2 restart Nodepay' 命令来重启服务。"

    # 提示用户按任意键返回主菜单
    read -n 1 -s -r -p "按任意键返回主菜单..."
}

# 主菜单函数
function main_menu() {
    while true; do
        clear
        echo "脚本由大赌社区哈哈哈哈编写，推特 @ferdie_jhovie，免费开源，请勿相信收费"
        echo "如有问题，可联系推特，仅此只有一个号"
        echo "================================================================"
        echo "退出脚本，请按键盘 ctrl + C 退出即可"
        echo "请选择要执行的操作:"
        echo "5. 安装部署 Nodepay"
        echo "6. 退出"

        read -p "请输入您的选择 (5,6): " choice
        case $choice in
            5)
                setup_Nodepay  # 调用安装和配置函数
                ;;    
            6)
                echo "退出脚本..."
                exit 0
                ;;
            *)
                echo "无效的选择，请重试."
                read -n 1 -s -r -p "按任意键继续..."
                ;;
        esac
    done
}

# 进入主菜单
main_menu
