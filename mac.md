#!/bin/bash

# 定义 Cysic-Verifier 文件夹路径
CYSIC_DIR="$HOME/Cysic-Verifier"

function check_and_set_permissions() {
    echo "检查和设置权限..."
    
    if [ ! -x "$0" ]; then
        chmod +x "$0"
    fi
    
    if [ ! -d "$CYSIC_DIR" ]; then
        mkdir -p "$CYSIC_DIR"
        echo "创建了 Cysic-Verifier 文件夹。"
    fi
    chmod 755 "$CYSIC_DIR"
    
    if [ -f "$CYSIC_DIR/verifier" ]; then
        chmod 755 "$CYSIC_DIR/verifier"
    fi
    if [ -f "$CYSIC_DIR/libzkp.dylib" ]; then
        chmod 644 "$CYSIC_DIR/libzkp.dylib"
    fi
    
    echo "权限检查和设置完成。"
}

function download_and_configure() {
    echo "开始下载并配置 Cysic Verifier..."
    
    rm -rf "$CYSIC_DIR"
    mkdir -p "$CYSIC_DIR"
    curl -L https://cysic-verifiers.oss-accelerate.aliyuncs.com/verifier_mac > "$CYSIC_DIR/verifier"
    curl -L https://cysic-verifiers.oss-accelerate.aliyuncs.com/libzkp.dylib > "$CYSIC_DIR/libzkp.dylib"

    cat << EOF > "$CYSIC_DIR/config.yaml"
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
claim_reward_address: "0x696969696969"

server:
  # don't modify this
  cysic_endpoint: "https://api-testnet.prover.xyz"
EOF

    echo "请输入您的奖励地址（EVM地址）："
    read reward_address
    
    sed -i '' "s/0x696969696969/$reward_address/" "$CYSIC_DIR/config.yaml"
    
    echo "配置完成。您的奖励地址已更新为：$reward_address"
    echo "配置文件内容如下："
    cat "$CYSIC_DIR/config.yaml"
    
    # 设置下载的文件权限
    chmod 755 "$CYSIC_DIR/verifier"
    chmod 644 "$CYSIC_DIR/libzkp.dylib"
}

function start_verifier() {
    echo "正在启动 Cysic Verifier..."
    cd "$CYSIC_DIR"
    DYLD_LIBRARY_PATH=".:~/miniconda3/lib:$DYLD_LIBRARY_PATH" CHAIN_ID=534352 ./verifier
}

# 在脚本开始时检查和设置权限
check_and_set_permissions

while true; do
    echo
    echo "Cysic Verifier 控制面板"
    echo "1. 下载并配置 Cysic Verifier"
    echo "2. 启动 Cysic Verifier"
    echo "3. 退出"
    echo
    read -p "请选择操作 (1-3): " choice

    case $choice in
        1)
            download_and_configure
            ;;
        2)
            start_verifier
            ;;
        3)
            echo "感谢使用，再见！"
            exit 0
            ;;
        *)
            echo "无效的选择，请重新输入。"
            ;;
    esac

    echo
    read -p "按回车键继续..."
done
