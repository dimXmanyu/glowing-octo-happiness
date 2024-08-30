#!/bin/bash

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

# 安装必要的软件
apt update
apt install -y nodejs npm
npm install -g pm2

# 验证安装
node --version
npm --version
pm2 --version

# 下载验证器
rm -rf /home/ubuntu/cysic-verifier
mkdir /home/ubuntu/cysic-verifier
cd /home/ubuntu/cysic-verifier

curl -L https://cysic-verifiers.oss-accelerate.aliyuncs.com/verifier_linux > verifier
curl -L https://cysic-verifiers.oss-accelerate.aliyuncs.com/libzkp.so > libzkp.so

chmod +x verifier

# 提示用户输入奖励地址
read -p "请输入您的奖励地址: " reward_address

# 设置验证器配置
cat << EOF > config.yaml
chain:
  endpoint: "testnet-node-1.prover.xyz:9090"
  chain_id: "cysicmint_9000-1"
  gas_coin: "cysic"
  gas_price: 10
claim_reward_address: "${reward_address}"

server:
  cysic_endpoint: "https://api-testnet.prover.xyz"
EOF

# 创建启动脚本
cat << EOF > start.sh
#!/bin/bash
export LD_LIBRARY_PATH=.:~/miniconda3/lib
./verifier --config config.yaml
EOF

chmod +x start.sh

# 创建 PM2 配置文件
cat << EOF > verifier.config.js
module.exports = {
  apps : [{
    name: "cysic-verifier",
    script: "./start.sh",
    cwd: "/home/ubuntu/cysic-verifier",
    watch: false,
    autorestart: true,
    restart_delay: 10000,
    max_restarts: 10,
    env: {
      NODE_ENV: "production",
    }
  }]
}
EOF

# 使用 PM2 启动验证器
pm2 start verifier.config.js

# 设置 PM2 在系统启动时自动运行
pm2 startup
pm2 save

echo "验证器设置完成并已启动。您可以使用 'pm2 status' 查看运行状态。"
