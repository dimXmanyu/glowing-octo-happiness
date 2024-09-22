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
    "Verifier is running. Press any key to stop and return to the main menu."
    "Verifier stopped."
    "View PM2 Verifier logs"
    "Stop PM2 Verifier"
    "Uninstall Cysic Verifier"
    "Viewing PM2 Verifier logs. Press Ctrl+C to exit."
    "PM2 Verifier stopped."
    "Uninstalling Cysic Verifier..."
    "Cysic Verifier has been uninstalled."
    "Configure Swap Memory"
    "Swap memory configured successfully."
)

msgs_zh=(
    "选择语言："
    "请输入您的选择： "
    "无效的选择。请重试。"
    "Cysic 验证器管理菜单"
    "安装 Node.js 和 PM2"
    "下载并配置 Cysic 验证器"
    "设置奖励地址"
    "首次启动验证器"
    "使用 PM2 管理验证器"
    "退出"
    "更改语言"
    "输入奖励地址： "
    "Cysic 验证器配置完成。"
    "验证器已启动。按任意键返回主菜单..."
    "地址格式无效。请输入有效的以太坊地址（0x 后跟 40 个十六进制字符）。"
    "更新奖励地址失败。请手动检查 config.yaml 文件。"
    "PM2 配置完成。系统重启后验证器将自动启动。"
    "验证器正在运行。按任意键停止并返回主菜单。"
    "验证器已停止。"
    "查看 PM2 验证器日志"
    "停止 PM2 验证器"
    "卸载 Cysic 验证器"
    "正在查看 PM2 验证器日志。按 Ctrl+C 退出。"
    "PM2 验证器已停止。"
    "正在卸载 Cysic 验证器..."
    "Cysic 验证器已卸载。"
    "配置 Swap 内存"
    "Swap 内存配置成功。"
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
    "검증자가 시작되었습니다. 아무 키나 눌러 메인 메뉴로 돌아가세요..."
    "잘못된 주소 형식입니다. 유효한 이더리움 주소를 입력하세요 (0x 다음에 40개의 16진수 문자)."
    "보상 주소 업데이트에 실패했습니다. config.yaml 파일을 수동으로 확인해주세요."
    "PM2 구성이 완료되었습니다. 시스템 재부팅 후 검증자가 자동으로 시작됩니다."
    "검증자가 실행 중입니다. 아무 키나 눌러 중지하고 메인 메뉴로 돌아가세요."
    "검증자가 중지되었습니다."
    "PM2 검증자 로그 보기"
    "PM2 검증자 중지"
    "Cysic 검증자 제거"
    "PM2 검증자 로그를 보고 있습니다. 종료하려면 Ctrl+C를 누르세요."
    "PM2 검증자가 중지되었습니다."
    "Cysic 검증자를 제거하는 중..."
    "Cysic 검증자가 제거되었습니다."
    "스왑 메모리 구성"
    "스왑 메모리가 성공적으로 구성되었습니다."
)

LANG_OPTIONS=("English" "中文" "한국어")

LANGUAGE=2
msgs=("${msgs_zh[@]}")

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

show_menu() {
    echo "----------------------------------------"
    echo "${msgs[3]}"
    echo "----------------------------------------"
    echo "1. ${msgs[10]}"
    echo "2. ${msgs[4]}"
    echo "3. ${msgs[5]}"
    echo "4. ${msgs[6]}"
    echo "5. ${msgs[7]}"
    echo "6. ${msgs[8]}"
    echo "7. ${msgs[19]}"
    echo "8. ${msgs[20]}"
    echo "9. ${msgs[21]}"
    echo "10. ${msgs[9]}"
    echo "11. ${msgs[26]}" 
    echo "----------------------------------------"
}

configure_swap() {
    sudo -i <<EOF
fallocate -l 4G /swapfile.img
chmod 600 /swapfile.img
mkswap /swapfile.img
swapon /swapfile.img
echo '/swapfile.img swap swap defaults 0 0' >> /etc/fstab
exit
EOF
    echo "${msgs[27]}"  # Swap 内存配置成功。
}

install_node_pm2() {
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
    sudo npm install pm2 -g
}

download_configure_verifier() {
    echo "Configuring Cysic Verifier..."
    rm -rf ~/cysic-verifier
    cd ~
    mkdir cysic-verifier
    curl -L https://cysic-verifiers.oss-accelerate.aliyuncs.com/verifier_linux > ~/cysic-verifier/verifier
    curl -L https://cysic-verifiers.oss-accelerate.aliyuncs.com/libzkp.so > ~/cysic-verifier/libzkp.so
    chmod +x ~/cysic-verifier/verifier
    
    cat << EOF > ~/cysic-verifier/config.yaml
chain:
  endpoint: "testnet-node-1.prover.xyz:9090"
  chain_id: "cysicmint_9000-1"
  gas_coin: "cysic"
  gas_price: 10
claim_reward_address: "0x696969"

server:
  cysic_endpoint: "https://api-testnet.prover.xyz"
EOF

    echo "Cysic Verifier configuration completed."
    echo "Please remember to modify the claim_reward_address in ~/cysic-verifier/config.yaml"
}

set_reward_address() {
    read -p "${msgs[11]}" reward_address
    if [[ ! "$reward_address" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
        echo "${msgs[14]}"
        return
    fi
    
    sed -i "s|claim_reward_address: \"0x.*\"|claim_reward_address: \"$reward_address\"|" ~/cysic-verifier/config.yaml

    if grep -q "claim_reward_address: \"$reward_address\"" ~/cysic-verifier/config.yaml; then
        echo "${msgs[12]}"
    else
        echo "${msgs[15]}"
    fi
}

start_verifier() {
    cd ~/cysic-verifier/
    export LD_LIBRARY_PATH=.:~/miniconda3/lib
    export CHAIN_ID=534352
    chmod +x verifier
    
    echo "${msgs[13]}"  # "验证器正在启动。日志信息将会显示..."
    
    # 使用 timeout 命令运行验证器，允许在任意时刻通过按键中断
    timeout --foreground --preserve-status 86400 ./verifier &
    verifier_pid=$!
    
    echo "${msgs[17]}"  # "验证器正在运行。按任意键停止并返回主菜单。"
    read -n 1 -s -r
    
    # 停止验证器进程
    kill $verifier_pid 2>/dev/null
    
    echo "${msgs[18]}"  # "验证器已停止。"
    sleep 2
    clear
}

manage_verifier_pm2() {
    # 创建启动脚本
    cat << EOF > ~/cysic-verifier/start.sh
#!/bin/bash
export LD_LIBRARY_PATH=.:~/miniconda3/lib
export CHAIN_ID=534352
cd ~/cysic-verifier
./verifier
EOF

    # 添加执行权限
    chmod +x ~/cysic-verifier/start.sh

    # 使用 PM2 启动验证器
    pm2 start ~/cysic-verifier/start.sh --name cysic-verifier

    # 配置 PM2 在系统重启后自动启动验证器
    pm2 startup
    pm2 save

    echo "${msgs[16]}"  # 添加一个新的消息："PM2 配置完成，验证器将在系统重启后自动启动。"
    read -n 1 -s -r
    clear
    show_menu
}

view_pm2_logs() {
    echo "${msgs[22]}"
    pm2 logs cysic-verifier
}

stop_pm2_verifier() {
    pm2 stop cysic-verifier
    echo "${msgs[23]}"
}

uninstall_verifier() {
    echo "${msgs[24]}"
    pm2 delete cysic-verifier 2>/dev/null
    rm -rf ~/cysic-verifier
    echo "${msgs[25]}"
}

while true; do
    show_menu
    read -p "${msgs[1]}" choice
case $choice in
    1) change_language ;;
    2) install_node_pm2 ;;
    3) download_configure_verifier ;;
    4) set_reward_address ;;
    5) start_verifier ;;
    6) manage_verifier_pm2 ;;
    7) view_pm2_logs ;;
    8) stop_pm2_verifier ;;
    9) uninstall_verifier ;;
    10) exit 0 ;;
    11) configure_swap ;; 
    *) echo "${msgs[2]}" ;;
esac
    echo
done
