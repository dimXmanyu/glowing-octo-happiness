#!/bin/bash

# 脚本保存路径
SCRIPT_PATH="$HOME/layeredge.sh"

# 主菜单函数
function main_menu() {
    while true; do
        clear
        echo "================================================================"
        echo "LayerEdge 节点部署脚本"
        echo "================================================================"
        echo "请选择要执行的操作:"
        echo "1. 部署 LayerEdge 节点"
        echo "2. 查看节点日志"
        echo "3. 查看节点状态"
        echo "4. 重启节点"
        echo "5. 停止节点"
        echo "6. 退出脚本"
        echo "================================================================"
        read -p "请输入选择 (1-6): " choice

        case $choice in
            1)  deploy_layeredge_node ;;
            2)  view_node_logs ;;
            3)  check_node_status ;;
            4)  restart_node ;;
            5)  stop_node ;;
            6)  exit ;;
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
    fi

    # 安装 PM2
    if ! command -v pm2 &> /dev/null; then
        echo "正在安装 PM2..."
        npm install -g pm2
    fi

    echo "环境依赖检测完成！"
}

# 查看节点日志
function view_node_logs() {
    if pm2 list | grep -q "layeredge"; then
        clear
        echo "正在查看节点日志..."
        pm2 logs layeredge
    else
        echo "节点未运行，无法查看日志"
        sleep 2
    fi
}

# 检查节点状态
function check_node_status() {
    if command -v pm2 &> /dev/null; then
        pm2 status layeredge
        read -n 1 -s -r -p "按任意键返回主菜单..."
    else
        echo "未安装 PM2，请先部署节点"
        sleep 2
    fi
}

# 重启节点
function restart_node() {
    echo "开始循环重启节点..."
    echo "按 Ctrl+C 可以停止循环重启"
    
    while true; do
        if pm2 list | grep -q "layeredge"; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') - 正在重启节点..."
            cd ~/LayerEdge && pm2 restart layeredge
            echo "$(date '+%Y-%m-%d %H:%M:%S') - 节点已重启成功！"
        else
            echo "$(date '+%Y-%m-%d %H:%M:%S') - 节点未运行，正在启动..."
            cd ~/LayerEdge && pm2 start "npm start" --name "layeredge"
            echo "$(date '+%Y-%m-%d %H:%M:%S') - 节点已启动成功！"
        fi
        
        echo "$(date '+%Y-%m-%d %H:%M:%S') - 等待1分钟后进行下一次重启..."
        sleep 60
    done
}

# 停止节点
function stop_node() {
    if pm2 list | grep -q "layeredge"; then
        echo "正在停止节点..."
        pm2 delete layeredge
        echo "节点已停止并删除成功！"
    else
        echo "节点未运行"
    fi
    sleep 2
}

# 部署 layeredge 节点
function deploy_layeredge_node() {
    # 检测并安装环境依赖
    install_dependencies

    # 创建工作目录
    cd $HOME

    # 检查目标目录是否存在
    if [ -d "LayerEdge" ]; then
        echo "检测到 LayerEdge 目录已存在。"
        read -p "是否删除旧目录并重新拉取仓库？(y/n) " delete_old
        if [[ "$delete_old" =~ ^[Yy]$ ]]; then
            echo "正在删除旧目录..."
            rm -rf LayerEdge
            echo "旧目录已删除。"
        else
            echo "跳过拉取仓库，使用现有目录。"
            read -n 1 -s -r -p "按任意键继续..."
            echo "使用现有目录继续运行..."
            cd LayerEdge
            pm2 delete layeredge 2>/dev/null
            npm install
            pm2 start "npm start" --name "layeredge"
            echo "节点已重新启动！"
            read -n 1 -s -r -p "按任意键返回主菜单..."
            return
        fi
    fi

    # 拉取仓库
    if git clone https://github.com/sdohuajia/LayerEdge.git; then
        echo "仓库拉取成功！"
    else
        echo "仓库拉取失败，请检查网络连接或仓库地址。"
        read -n 1 -s -r -p "按任意键返回主菜单..."
        main_menu
        return
    fi

    # 进入项目目录
    cd LayerEdge || {
        echo "进入目录失败，请检查是否成功拉取仓库。"
        read -n 1 -s -r -p "按任意键返回主菜单..."
        main_menu
        return
    }

    # 输入钱包信息并保存到正确位置
    read -p "请输入钱包地址: " wallet_address
    read -p "请输入私钥: " private_key
    # 确保在 LayerEdge 目录下保存 wallets.txt
    echo "$wallet_address,$private_key" > ./wallets.txt
    
    # 验证文件是否创建成功
    if [ ! -f "./wallets.txt" ]; then
        echo "钱包配置文件创建失败！"
        read -n 1 -s -r -p "按任意键返回主菜单..."
        main_menu
        return
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

    # 先确保没有同名的 PM2 进程
    pm2 delete layeredge 2>/dev/null
    # 使用 PM2 启动项目
    echo "正在使用 PM2 启动项目..."
    pm2 start "npm start" --name "layeredge"

    echo "项目已成功启动！"
    echo "可以使用以下命令查看运行状态："
    echo "pm2 logs layeredge - 查看日志"
    echo "pm2 restart layeredge - 重启节点"
    echo "pm2 delete layeredge - 停止节点"
    echo "pm2 status"
    echo "查看日志："
    echo "pm2 logs layeredge"

    # 提示用户按任意键返回主菜单
    read -n 1 -s -r -p "按任意键返回主菜单..."
    main_menu
}

# 调用主菜单函数
main_menu
