#!/bin/bash

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
    "Cysic Verifier configuration completed."
    "Verifier started. Press any key to return to the main menu..."
    "Invalid address format. Please enter a valid Ethereum address (0x followed by 40 hexadecimal characters)."
    "Failed to update reward address. Please check the config.yaml file manually."
    "PM2 configuration completed. The verifier will start automatically after system reboot."
)

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
    "Cysic 验证器配置完成。"
    "验证器已启动。按任意键返回主菜单..."
    "地址格式无效。请输入有效的以太坊地址（0x后跟40个十六进制字符）。"
    "更新奖励地址失败。请手动检查config.yaml文件。"
    "PM2 配置完成，验证器将在系统重启后自动启动。"
)

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
    "Cysic 검증자 구성이 완료되었습니다."
    "검증기가 시작되었습니다. 아무 키나 눌러 메인 메뉴로 돌아가세요..."
    "주소 형식이 잘못되었습니다. 유효한 이더리움 주소를 입력하세요 (0x로 시작하는 40개의 16진수 문자)."
    "보상 주소 업데이트에 실패했습니다. config.yaml 파일을 수동으로 확인해주세요."
    "PM2 구성이 완료되었습니다. 검증기는 시스템 재부팅 후 자동으로 시작됩니다."
)

LANG_OPTIONS=("English" "中文" "한국어")

LANGUAGE=2
msgs=("${msgs_zh[@]}")

change_language() {
    echo "${msgs[0]}"
    for i in "${!LANG_OPTIONS[@]}"; do
        echo "$((i+1)). ${LANG_OPTIONS[$i]}"
    done

    while true; do
        read -p "${msgs[1]}" choice
        case $choice in
            1) LANGUAGE=1; msgs=("${msgs_en[@]}"); break;;
            2) LANGUAGE=2; msgs=("${msgs_zh[@]}"); break;;
            3) LANGUAGE=3; msgs=("${msgs_ko[@]}"); break;;
            *) echo "${msgs[2]}";;
        esac
    done
}

install_nodejs_pm2() {
    curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
    sudo apt-get install -y nodejs
    sudo npm install pm2 -g
    echo "Node.js and PM2 installed successfully."
}

download_configure_verifier() {
    git clone https://github.com/cysic-labs/cysic-verifier.git
    cd cysic-verifier
    npm install
    echo "Cysic Verifier downloaded and configured."
}

set_reward_address() {
    while true; do
        read -p "${msgs[11]}" address
        if [[ $address =~ ^0x[a-fA-F0-9]{40}$ ]]; then
            sed -i "s/rewardAddress: .*/rewardAddress: \"$address\"/" config.yaml
            if [ $? -eq 0 ]; then
                echo "${msgs[12]}"
                break
            else
                echo "${msgs[16]}"
            fi
        else
            echo "${msgs[15]}"
        fi
    done
}

start_verifier() {
    node index.js
    echo "${msgs[13]}"
    read -n 1 -s -r -p ""
}

manage_verifier_pm2() {
    pm2 start index.js --name cysic-verifier
    pm2 save
    pm2 startup
    echo "${msgs[17]}"
}

display_menu() {
    clear
    echo "============================"
    echo "${msgs[3]}"
    echo "============================"
    echo "1. ${msgs[4]}"
    echo "2. ${msgs[5]}"
    echo "3. ${msgs[6]}"
    echo "4. ${msgs[7]}"
    echo "5. ${msgs[8]}"
    echo "6. ${msgs[10]}"
    echo "7. ${msgs[9]}"
    echo "============================"
}

main() {
    while true; do
        display_menu
        read -p "${msgs[1]}" choice
        case $choice in
            1) install_nodejs_pm2 ;;
            2) download_configure_verifier ;;
            3) set_reward_address ;;
            4) start_verifier ;;
            5) manage_verifier_pm2 ;;
            6) change_language ;;
            7) break ;;
            *) echo "${msgs[2]}" ;;
        esac
    done
    echo "Exiting..."
}

main
