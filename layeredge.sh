#!/bin/bash

# 脚本保存路径
SCRIPT_PATH="$HOME/layeredge.sh"

# 主菜单函数
function main_menu() {
    while true; do
        clear
        echo "================================================================"
        echo "请选择要执行的操作:"
        echo "1. 部署 layeredge 节点"
        echo "2. 退出脚本"
        echo "================================================================"
        read -p "请输入选择 (1/2): " choice

        case $choice in
            1)  deploy_layeredge_node ;;
            2)  exit ;;
            *)  echo "无效选择，请重新输入！"; sleep 2 ;;
        esac
    done
}

# 检测并安装环境依赖
function install_dependencies() {
    echo "正在检测系统环境依赖..."

    # 检测并安装 git
    if ! command -v git &> /dev/null; then
        echo "未找到 git，正在安装 git..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y git
        elif command -v yum &> /dev/null; then
            sudo yum install -y git
        elif command -v brew &> /dev/null; then
            brew install git
        else
            echo "无法自动安装 git，请手动安装 git 后重试。"
            exit 1
        fi
        echo "git 安装完成！"
    else
        echo "git 已安装。"
    fi

    # 检测并安装 node 和 npm
    if ! command -v node &> /dev/null || ! command -v npm &> /dev/null; then
        echo "未找到 node 或 npm，正在安装 node 和 npm..."
        if command -v apt-get &> /dev/null; then
            curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
            sudo apt-get install -y nodejs
        elif command -v yum &> /dev/null; then
            curl -fsSL https://rpm.nodesource.com/setup_16.x | sudo -E bash -
            sudo yum install -y nodejs
        elif command -v brew &> /dev/null; then
            brew install node
        else
            echo "无法自动安装 node 和 npm，请手动安装 node 和 npm 后重试。"
            exit 1
        fi
        echo "node 和 npm 安装完成！"
    else
        echo "node 和 npm 已安装。"
    fi

    # 安装 PM2
    if ! command -v pm2 &> /dev/null; then
        echo "正在安装 PM2..."
        npm install -g pm2
        echo "PM2 安装完成！"
    else
        echo "PM2 已安装。"
    fi

    echo "环境依赖检测完成！"
}

# 部署 layeredge 节点
function deploy_layeredge_node() {
    # 检测并安装环境依赖
    install_dependencies

    # 检查目录是否存在
    if [ ! -d "$HOME/LayerEdge" ]; then
        echo "正在拉取仓库..."
        if git clone https://github.com/sdohuajia/LayerEdge.git ~/LayerEdge; then
            echo "仓库拉取成功！"
        else
            echo "仓库拉取失败，请检查网络连接或仓库地址。"
            read -n 1 -s -r -p "按任意键返回主菜单..."
            main_menu
            return
        fi
    else
        echo "检测到已存在 LayerEdge 目录，跳过仓库拉取..."
    fi

    # 进入项目目录
    cd ~/LayerEdge || exit

    # 创建启动脚本
    cat > start.js << EOL
const { exec } = require('child_process');
const path = require('path');

function runScript() {
    const npm = exec('npm start', {
        cwd: process.cwd()
    });

    npm.stdout.on('data', (data) => {
        console.log(data.toString());
    });

    npm.stderr.on('data', (data) => {
        console.error(data.toString());
    });

    npm.on('close', (code) => {
        console.log(\`进程退出，退出码: \${code}\`);
        setTimeout(runScript, 60000); // 1分钟后重新启动
    });
}

runScript();
EOL

    # 输入钱包信息
    if [ ! -f "wallets.txt" ]; then
        echo "请输入钱包信息，格式必须为：钱包地址,私钥"
        echo "每次输入一个钱包，直接按回车结束输入："
        > wallets.txt
        while true; do
            read -p "钱包地址：" wallet_address
            if [ -z "$wallet_address" ]; then
                if [ -s "wallets.txt" ]; then
                    break
                else
                    echo "钱包地址不能为空，请重新输入！"
                    continue
                fi
            fi

            read -p "私钥：" private_key
            if [ -z "$private_key" ]; then
                echo "私钥不能为空，请重新输入！"
                continue
            fi

            echo "$wallet_address,$private_key" >> wallets.txt
            echo "钱包信息已保存。"
        done
    else
        echo "检测到已存在钱包配置文件，跳过钱包配置..."
    fi

    # 安装依赖
    echo "正在使用 npm 安装依赖..."
    if npm install; then
        echo "依赖安装成功！"
    else
        echo "依赖安装失败，请检查网络连接或 npm 配置。"
        read -n 1 -s -r -p "按任意键返回主菜单..."
        main_menu
        return
    fi

    # 使用 PM2 启动项目
    echo "正在使用 PM2 启动项目..."
    pm2 delete layeredge 2>/dev/null
    pm2 start start.js --name layeredge
    pm2 save

    echo "项目已成功启动！"
    echo "你可以使用以下命令查看运行状态："
    echo "pm2 logs layeredge"
    echo "pm2 status"

    # 提示用户按任意键返回主菜单
    read -n 1 -s -r -p "按任意键返回主菜单..."
    main_menu
}

# 调用主菜单函数
main_menu
