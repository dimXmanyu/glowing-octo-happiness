#!/bin/bash

# 下载并解压 ubuntu-node-v1.0
wget https://network3.io/ubuntu-node-v1.0.tar
tar -xf ubuntu-node-v1.0.tar

# 切换到 network3 目录并运行 manager.sh up
cd network3
sudo bash manager.sh up

# 返回上级目录
cd ..

# 下载并解压 ubuntu-node-v1.1
wget https://network3.io/ubuntu-node-v1.1.tar
tar -xf ubuntu-node-v1.1.tar

# 切换到 network3 目录并运行 manager.sh key
cd network3
sudo bash manager.sh key

# 给 manager.sh 赋予执行权限
sudo chmod +x manager.sh

echo "所有命令已成功执行！"
