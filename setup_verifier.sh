#!/bin/bash

# 作者: mang
# 免责声明: 本脚本仅供学习和参考使用，作者不对使用本脚本造成的任何损失负责。

echo "欢迎使用验证器安装脚本！"

# 检查是否以 root 权限运行
if [ "$EUID" -ne 0 ]; then
  echo "请以 root 权限运行此脚本"
  exit 1
fi

# 扩展虚拟内存
fallocate -l 4G /swapfile.img
chmod 600 /swapfile.img
mkswap /swapfile.img
swapon /swapfile.img
echo '/swapfile.img swap swap defaults 0 0' >> /etc/fstab

# 安装 Node.js 和 npm
apt update
apt install -y nodejs npm

# 安装 PM2
npm install -g pm2

# 下载验证器
rm -rf /home/ubuntu/cysic-verifier
mkdir -p /home/ubuntu/cysic-verifier
cd /home/ubuntu/cysic-verifier

curl -L https://cysic-verifiers.oss-accelerate.aliyuncs.com/verifier_linux > verifier
curl -L https://cysic-verifiers.oss-accelerate.aliyuncs.com/libzkp.so > libzkp.so
chmod +x verifier

# 提示用户输入奖励地址
read -p "请输入您的奖励地址 (EVM 地址): " reward_address

# 设置验证器配置
cat << EOF > /home/ubuntu/cysic-verifier/config.yaml
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
claim_reward_address: "${reward_address}"

server:
  # don't modify this
  cysic_endpoint: "https://api-testnet.prover.xyz"
EOF

# 创建健康检查脚本
cat << EOF > /home/ubuntu/cysic-verifier/health_check.sh
#!/bin/bash
if ! pgrep -f "./verifier --config" > /dev/null
then
    echo "Verifier is not running. Restarting..."
    pm2 restart cysic-verifier
fi
EOF

chmod +x /home/ubuntu/cysic-verifier/health_check.sh

# 使用 PM2 启动验证器，并设置健康检查
pm2 start ./verifier --name cysic-verifier -- --config ./
pm2 start /home/ubuntu/cysic-verifier/health_check.sh --name verifier-health-check --cron "*/5 * * * *"

# 设置 PM2 在系统重启后自动启动
pm2 startup
pm2 save

echo "验证器安装完成并已启动！"
echo "使用以下命令查看验证器状态："
echo "pm2 status cysic-verifier"
echo "使用以下命令查看验证器日志："
echo "pm2 logs cysic-verifier"
echo "验证器将在掉线后自动重启。"
echo "健康检查脚本每5分钟运行一次，确保验证器持续运行。"
echo "如需手动重启验证器，请使用命令："
echo "pm2 restart cysic-verifier"

# 提醒用户重启系统以应用所有更改
echo "建议重启系统以确保所有更改生效。"
echo "您可以使用以下命令重启系统："
echo "sudo reboot"
