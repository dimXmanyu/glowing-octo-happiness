#!/bin/bash

# 定义语言选项
declare -A LANG_OPTIONS
LANG_OPTIONS[1]="English"
LANG_OPTIONS[2]="中文"
LANG_OPTIONS[3]="한국어"

# 定义消息
declare -A MESSAGES
MESSAGES["menu_title"]="请选择一个操作："
MESSAGES["install_node_pm2"]="安装 Node.js 和 PM2"
MESSAGES["download_configure_verifier"]="下载并配置 Cysic Verifier"
MESSAGES["set_reward_address"]="设置奖励地址"
MESSAGES["start_verifier_first_time"]="首次启动 Verifier"
MESSAGES["manage_verifier_pm2"]="使用 PM2 自动管理 Verifier"
MESSAGES["exit"]="退出"
MESSAGES["choose_language"]="请选择显示语言："
MESSAGES["invalid_choice"]="无效的选择，请重新输入。"
MESSAGES["input_reward_address"]="请输入奖励地址："

# 设置默认语言为中文
LANGUAGE=2

# 切换语言
change_language() {
    echo "${MESSAGES["choose_language"]}"
    echo "1) English"
    echo "2) 中文"
    echo "3) 한국어"
    read -p "输入您的选择: " lang_choice
    if [[ $lang_choice -ge 1 && $lang_choice -le 3 ]]; then
        LANGUAGE=$lang_choice
    else
        echo "${MESSAGES["invalid_choice"]}"
    fi
}

# 显示菜单
show_menu() {
    echo "${MESSAGES["menu_title"]}"
    echo "1) ${MESSAGES["choose_language"]}"
    echo "2) ${MESSAGES["install_node_pm2"]}"
    echo "3) ${MESSAGES["set_reward_address"]}"
    echo "4) ${MESSAGES["start_verifier_first_time"]}"
    echo "5) ${MESSAGES["manage_verifier_pm2"]}"
    echo "6) ${MESSAGES["exit"]}"
}

# 安装 Node.js 和 PM2
install_node_pm2() {
    echo "${MESSAGES["install_node_pm2"]}..."
    sudo apt update
    sudo apt install -y nodejs npm
    sudo npm install -g pm2
    echo "${MESSAGES["install_node_pm2"]} 完成。"
}

# 下载并配置 Cysic Verifier
download_configure_verifier() {
    echo "${MESSAGES["download_configure_verifier"]}..."
    rm -rf ~/cysic-verifier
    mkdir ~/cysic-verifier
    curl -L https://cysic-verifiers.oss-accelerate.aliyuncs.com/verifier_linux > ~/cysic-verifier/verifier
    curl -L https://cysic-verifiers.oss-accelerate.aliyuncs.com/libzkp.so > ~/cysic-verifier/libzkp.so

    cat <<EOF > ~/cysic-verifier/config.yaml
# Not Change
chain:
  # Not Change
  endpoint: "testnet-node-1.prover.xyz:9090"
  # Not Change
  chain_id: "cysicmint_9000-1"
  # Not Change
  gas_coin: "cysic"
  # Not Change
  gas_price: 10
  # Modify Here： ! Your Address (EVM) submitted to claim rewards
claim_reward_address: "0x696969"

server:
  # don't modify this
  cysic_endpoint: "https://api-testnet.prover.xyz"
EOF

    echo "${MESSAGES["download_configure_verifier"]} 完成。"
}

# 设置奖励地址
set_reward_address() {
    read -p "${MESSAGES["input_reward_address"]}" reward_address
    sed -i "s/claim_reward_address: \"0x696969\"/claim_reward_address: \"$reward_address\"/" ~/cysic-verifier/config.yaml
    echo "${MESSAGES["set_reward_address"]} 完成。"
}

# 首次启动 Verifier
start_verifier_first_time() {
    echo "${MESSAGES["start_verifier_first_time"]}..."
    cd ~/cysic-verifier/
    export LD_LIBRARY_PATH=.:~/miniconda3/lib
    export CHAIN_ID=534352
    chmod +x verifier
    ./verifier
    echo "${MESSAGES["start_verifier_first_time"]} 完成。"
}

# 使用 PM2 自动管理 Verifier
manage_verifier_pm2() {
    echo "${MESSAGES["manage_verifier_pm2"]}..."
    cd ~/cysic-verifier/
    export LD_LIBRARY_PATH=.:~/miniconda3/lib
    export CHAIN_ID=534352
    pm2 start ./verifier --name cysic-verifier
    pm2 save
    echo "${MESSAGES["manage_verifier_pm2"]} 完成。"
}

# 主循环
while true; do
    show_menu
    read -p "输入您的选择: " choice
    case $choice in
        1) change_language ;;
        2) 
            install_node_pm2
            download_configure_verifier
            ;;
        3) set_reward_address ;;
        4) start_verifier_first_time ;;
        5) manage_verifier_pm2 ;;
        6) 
            echo "${MESSAGES["exit"]}"
            exit 0
            ;;
        *) echo "${MESSAGES["invalid_choice"]}" ;;
    esac
    echo
done
