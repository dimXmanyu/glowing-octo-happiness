#!/bin/bash

# 确保脚本以 sudo 权限运行
if [ "$EUID" -ne 0 ]; then
  echo "请以 sudo 权限运行此脚本：sudo -i"
  exit 1
fi

# 脚本保存路径
SCRIPT_PATH="$HOME/Linux.sh"

# 检查 Docker 是否已安装
if ! command -v docker &> /dev/null; then
    echo "Docker 未安装，正在安装..."
    
    # 更新系统
    sudo apt update -y && sudo apt upgrade -y
    
    # 移除旧版本
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
        sudo apt-get remove -y $pkg
    done

    # 安装必要的包
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # 添加 Docker 的源
    echo \
      "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # 再次更新并安装 Docker
    sudo apt update -y && sudo apt upgrade -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # 检查 Docker 版本
    docker --version
else
    echo "Docker 已安装，版本为: $(docker --version)"
fi

# 获取相对路径
relative_path=$(realpath --relative-to=/usr/share/zoneinfo /etc/localtime)
echo "相对路径为: $relative_path"

# 创建 chromium 目录并进入
mkdir -p $HOME/chromium
cd $HOME/chromium
echo "已进入 chromium 目录"

# 获取用户输入
read -p "请输入 CUSTOM_USER: " CUSTOM_USER
read -sp "请输入 PASSWORD: " PASSWORD
echo
read -p "请输入代理IP（格式为 IP:PORT）: " PROXY_IP
read -p "请输入代理用户名: " PROXY_USER
read -sp "请输入代理密码: " PROXY_PASS
echo

# 创建 docker-compose.yaml 文件
cat <<EOF > docker-compose.yaml
version: '3.7'

services:
  chromium:
    build: .
    container_name: chromium
    environment:
      - CUSTOM_USER=$CUSTOM_USER
      - PASSWORD=$PASSWORD
      - PUID=1000
      - PGID=1000
      - TZ=Europe/London
      - SOCKS_PROXY=socks5://$PROXY_USER:$PROXY_PASS@$PROXY_IP
    volumes:
      - /root/chromium/config:/config
    ports:
      - 3010:3000   # Change 3010 to your favorite port if needed
      - 3011:3001   # Change 3011 to your favorite port if needed
    shm_size: "1gb"
    restart: unless-stopped
EOF

echo "docker-compose.yaml 文件已创建，内容已导入。"

# 创建 Dockerfile
cat <<EOF > Dockerfile
# 使用官方的 Chromium 镜像作为基础镜像
FROM lscr.io/linuxserver/chromium:latest

# 安装必要的软件包
RUN apt-get update && apt-get install -y \
    libnss3-tools \
    && rm -rf /var/lib/apt/lists/*

# 添加启动脚本
COPY start-chromium.sh /usr/local/bin/start-chromium.sh
RUN chmod +x /usr/local/bin/start-chromium.sh

# 设置启动命令
CMD ["start-chromium.sh"]
EOF

echo "Dockerfile 已创建。"

# 创建 start-chromium.sh 脚本
cat <<EOF > start-chromium.sh
#!/bin/bash

# 从环境变量获取代理设置
SOCKS_PROXY="${SOCKS_PROXY:-socks5://user:password@proxy_ip:proxy_port}"

# 启动 Chrome 并配置代理
chromium-browser --proxy-server="\$SOCKS_PROXY" --no-sandbox --disable-dev-shm-usage
EOF

chmod +x start-chromium.sh

echo "start-chromium.sh 脚本已创建并赋予执行权限。"

# 构建和启动 Docker Compose
docker compose up -d --build
echo "Docker Compose 已启动。"

echo "部署完成，请打开浏览器操作。"
