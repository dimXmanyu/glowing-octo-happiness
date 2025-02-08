#!/bin/bash

# 检查是否安装了必要的软件
check_dependencies() {
    command -v git >/dev/null 2>&1 || { echo "需要安装 git"; exit 1; }
    command -v node >/dev/null 2>&1 || { echo "需要安装 Node.js"; exit 1; }
    command -v npm >/dev/null 2>&1 || { echo "需要安装 npm"; exit 1; }
    command -v pm2 >/dev/null 2>&1 || { echo "正在安装 PM2..."; npm install -g pm2; }
}

# 克隆项目
clone_project() {
    echo "正在克隆项目..."
    git clone https://github.com/Svz1404/Galkurta-Ledge.git
    cd Galkurta-Ledge
}

# 安装依赖
install_dependencies() {
    echo "正在安装项目依赖..."
    npm install axios ethers figlet
}

# 配置钱包
configure_wallet() {
    echo "=== 钱包配置 ==="
    echo "请输入钱包私钥："
    read -r private_key
    
    # 确保在项目根目录
    cd Galkurta-Ledge
    
    # 将私钥写入 data.txt
    echo "$private_key" > data.txt
    
    echo "钱包配置完成！私钥已保存到 data.txt"
}

# 使用 PM2 启动项目
start_project() {
    echo "正在启动项目..."
    pm2 start main.js --name "galkurta-ledge"
    echo "项目已启动！可以使用 'pm2 logs' 查看日志"
    echo "使用 'pm2 stop galkurta-ledge' 停止项目"
}

# 主函数
main() {
    check_dependencies
    clone_project
    install_dependencies
    configure_wallet
    start_project
}

# 执行主函数
main
