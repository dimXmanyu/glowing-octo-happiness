#!/bin/bash

# 下载并解压 ubuntu-node-v1.0
wget https://network3.io/ubuntu-node-v1.0.tar
tar -xf ubuntu-node-v1.0.tar

# 切换到目录并运行 manager.sh up
cd ubuntu-node
sudo bash manager.sh up

# 返回上级目录
cd ..

# 下载并解压 ubuntu-node-v1.1
wget https://network3.io/ubuntu-node-v1.1.tar
tar -xf ubuntu-node-v1.1.tar

# 切换到目录并运行 manager.sh key
cd ubuntu-node
sudo bash manager.sh key

echo "所有命令已成功执行！"
