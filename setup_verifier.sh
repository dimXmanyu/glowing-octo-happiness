#!/bin/bash

# 英文消息
msgs_en=(
    "Choose language:"
    "Enter your choice: "
    "Invalid choice. Please try again."
    "Cysic Verifier Management Menu"
    "Install Node.js and PM2"
    "Download and configure Cysic Verifier"
    "Set reward address"
    "Start Verifier for the first time"
    "Manage Verifier with PM2"
    "Exit"
    "Change Language"
    "Enter reward address: "
)

# 中文消息
msgs_zh=(
    "选择语言："
    "请输入您的选择："
    "无效的选择。请重试。"
    "Cysic 验证器管理菜单"
    "安装 Node.js 和 PM2"
    "下载并配置 Cysic 验证器"
    "设置奖励地址"
    "首次启动验证器"
    "使用 PM2 管理验证器"
    "退出"
    "更改语言"
    "输入奖励地址："
)

# 韩文消息
msgs_ko=(
    "언어 선택:"
    "선택을 입력하세요: "
    "잘못된 선택입니다. 다시 시도해주세요."
    "Cysic 검증자 관리 메뉴"
    "Node.js 및 PM2 설치"
    "Cysic 검증자 다운로드 및 구성"
    "보상 주소 설정"
    "검증자 처음 시작"
    "PM2로 검증자 관리"
    "종료"
    "언어 변경"
    "보상 주소 입력: "
)

LANG_OPTIONS=("English" "中文" "한국어")

# 默认语言为中文
LANGUAGE=2
msgs=("${msgs_zh[@]}")

# 切换语言
change_language() {
    echo "${msgs[0]}"
    for i in "${!LANG_OPTIONS[@]}"; do
        echo "$((i+1))) ${LANG_OPTIONS[$i]}"
    done
    read -p "${msgs[1]}" lang_choice
    if [[ $lang_choice -ge 1 && $lang_choice -le 3 ]]; then
        LANGUAGE=$lang_choice
        case $LANGUAGE in
            1) msgs=("${msgs_en[@]}") ;;
            2) msgs=("${msgs_zh[@]}") ;;
            3) msgs=("${msgs_ko[@]}") ;;
        esac
    else
        echo "${msgs[2]}"
    fi
}

# 显示菜单
show_menu() {
    echo "${msgs[3]}"
    echo "1) ${msgs[4]}"
    echo "2) ${msgs[5]}"
    echo "3) ${msgs[6]}"
    echo "4) ${msgs[7]}"
    echo "5) ${msgs[8]}"
    echo "6) ${msgs[9]}"
    echo "7) ${msgs[10]}"
}

# 安装 Node.js 和 PM2
install_node_pm2() {
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
    sudo npm install pm2 -g
}

# 下载并配置 Cysic Verifier
download_configure_verifier() {
    git clone https://github.com/cysic-labs/cysic-verifier.git
    cd cysic-verifier
    npm install
}

# 设置奖励地址
set_reward_address() {
    read -p "${msgs[11]}" reward_address
    echo "REWARD_ADDRESS=$reward_address" > .env
}

# 首次启动验证器
start_verifier_first_time() {
    npm run start
}

# 使用 PM2 管理验证器
manage_verifier_pm2() {
    pm2 start npm --name "cysic-verifier" -- run start
    pm2 save
    pm2 startup
}

# 主循环
while true; do
    show_menu
    read -p "${msgs[1]}" choice
    case $choice in
        1) install_node_pm2 ;;
        2) download_configure_verifier ;;
        3) set_reward_address ;;
        4) start_verifier_first_time ;;
        5) manage_verifier_pm2 ;;
        6) exit 0 ;;
        7) change_language ;;
        *) echo "${msgs[2]}" ;;
    esac
    echo
done
