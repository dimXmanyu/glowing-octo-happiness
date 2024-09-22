#!/bin/bash

# 定义语言选项
declare -A LANG_OPTIONS
LANG_OPTIONS[1]="English"
LANG_OPTIONS[2]="中文"
LANG_OPTIONS[3]="한국어"

# English messages
declare -A msgs_en
msgs_en[menu_title]="Please choose an operation:"
msgs_en[install_node_pm2]="Install Node.js and PM2"
msgs_en[download_configure_verifier]="Download and configure Cysic Verifier"
msgs_en[set_reward_address]="Set reward address"
msgs_en[start_verifier_first_time]="Start Verifier for the first time"
msgs_en[manage_verifier_pm2]="Manage Verifier with PM2"
msgs_en[exit]="Exit"
msgs_en[choose_language]="Please select a language:"
msgs_en[invalid_choice]="Invalid choice, please try again."
msgs_en[input_reward_address]="Please enter the reward address:"
msgs_en[input_choice]="Enter your choice"

# Chinese messages
declare -A msgs_zh
msgs_zh[menu_title]="请选择一个操作："
msgs_zh[install_node_pm2]="安装 Node.js 和 PM2"
msgs_zh[download_configure_verifier]="下载并配置 Cysic Verifier"
msgs_zh[set_reward_address]="设置奖励地址"
msgs_zh[start_verifier_first_time]="首次启动 Verifier"
msgs_zh[manage_verifier_pm2]="使用 PM2 自动管理 Verifier"
msgs_zh[exit]="退出"
msgs_zh[choose_language]="请选择显示语言："
msgs_zh[invalid_choice]="无效的选择，请重新输入。"
msgs_zh[input_reward_address]="请输入奖励地址："
msgs_zh[input_choice]="输入您的选择"

# Korean messages
declare -A msgs_ko
msgs_ko[menu_title]="작업을 선택하세요:"
msgs_ko[install_node_pm2]="Node.js 및 PM2 설치"
msgs_ko[download_configure_verifier]="Cysic 검증자 다운로드 및 구성"
msgs_ko[set_reward_address]="보상 주소 설정"
msgs_ko[start_verifier_first_time]="처음으로 검증자 시작"
msgs_ko[manage_verifier_pm2]="PM2로 검증자 관리"
msgs_ko[exit]="종료"
msgs_ko[choose_language]="언어를 선택하세요:"
msgs_ko[invalid_choice]="잘못된 선택입니다. 다시 시도하십시오."
msgs_ko[input_reward_address]="보상 주소를 입력하십시오:"
msgs_ko[input_choice]="선택을 입력하세요"

# 默认语言为中文
LANGUAGE=2
msgs=msgs_zh

# 切换语言
change_language() {
    echo "${msgs[choose_language]}"
    echo "1) English"
    echo "2) 中文"
    echo "3) 한국어"
    read -p "${msgs[input_choice]}: " lang_choice
    if [[ $lang_choice -ge 1 && $lang_choice -le 3 ]]; then
        LANGUAGE=$lang_choice
        case $LANGUAGE in
            1) msgs=msgs_en ;;
            2) msgs=msgs_zh ;;
            3) msgs=msgs_ko ;;
        esac
    else
        echo "${msgs[invalid_choice]}"
    fi
}

# 显示菜单
show_menu() {
    echo "${msgs[menu_title]}"
    echo "1) ${msgs[install_node_pm2]}"
    echo "2) ${msgs[download_configure_verifier]}"
    echo "3) ${msgs[set_reward_address]}"
    echo "4) ${msgs[start_verifier_first_time]}"
    echo "5) ${msgs[manage_verifier_pm2]}"
    echo "6) ${msgs[exit]}"
    echo "7) ${LANG_OPTIONS[$LANGUAGE]}"
}

# 安装 Node.js 和 PM2
install_node_pm2() {
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
    sudo npm install pm2 -g
}

# 下载并配置 Cysic Verifier
download_configure_verifier() {
    git clone https://github.com/cysic-labs/cysic-zk-verifier.git
    cd cysic-zk-verifier
    npm install
}

# 设置奖励地址
set_reward_address() {
    read -p "${msgs[input_reward_address]}" reward_address
    echo "REWARD_ADDRESS=$reward_address" > .env
}

# 首次启动 Verifier
start_verifier_first_time() {
    npm run start
}

# 使用 PM2 管理 Verifier
manage_verifier_pm2() {
    pm2 start npm --name "cysic-verifier" -- run start
    pm2 save
    pm2 startup
}

# 主循环
while true; do
    show_menu
    read -p "${msgs[input_choice]}: " choice
    case $choice in
        1) install_node_pm2 ;;
        2) download_configure_verifier ;;
        3) set_reward_address ;;
        4) start_verifier_first_time ;;
        5) manage_verifier_pm2 ;;
        6) exit 0 ;;
        7) change_language ;;
        *) echo "${msgs[invalid_choice]}" ;;
    esac
    echo
done
