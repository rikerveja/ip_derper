#!/bin/bash

# 1. 安装 Docker CE（Community Edition）
echo "开始安装 Docker..."

# 卸载旧版本的 Docker
sudo apt-get remove -y docker docker-engine docker.io containerd runc

# 更新 apt 包索引
sudo apt-get update

# 安装必要的依赖
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# 添加 Docker 官方 GPG 密钥
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# 添加 Docker 仓库
echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list

# 更新 apt 包索引
sudo apt-get update

# 安装 Docker CE
sudo apt-get install -y docker-ce

# 启动 Docker 服务并设置开机自启
sudo systemctl start docker
sudo systemctl enable docker

# 确保 Docker 正常运行
sudo systemctl status docker | grep "active (running)"

# 2. 配置 Docker 镜像加速器
echo "配置 Docker 镜像加速器..."

# 编辑 /etc/docker/daemon.json 文件，添加镜像加速器配置
sudo mkdir -p /etc/docker
echo '{
  "registry-mirrors": [
    "https://docker.imgdb.de"
  ]
}' | sudo tee /etc/docker/daemon.json

# 重启 Docker 服务使配置生效
sudo systemctl restart docker

echo "Docker 安装和配置完成！"

# 3. 拉取 Docker 镜像
echo "开始拉取 Docker 镜像..."

docker pull zhangjiayuan1983/ip_derper:latest

# 检查镜像是否成功下载
docker images

# 4. 随机生成端口并检查端口是否被占用
echo "开始随机生成端口..."

# 随机生成端口并检查端口是否已被占用
generate_random_ports() {
  local ports=()
  for i in {1..3}; do
    while true; do
      port=$((RANDOM % 20000 + 10000))
      netstat -tuln | grep ":$port" > /dev/null
      if [ $? -ne 0 ]; then
        ports+=($port)
        break
      fi
    done
  done
  echo "${ports[@]}"
}

# 生成端口
PORTS=($(generate_random_ports))

# 生成并显示端口
echo "随机生成的端口："
echo "HTTPS 端口：${PORTS[0]}"
echo "STUN 端口：${PORTS[1]}"
echo "Prometheus 监控端口：${PORTS[2]}"

# 5. 获取公网 IP 地址并格式化命名
SERVER_IP=$(curl -s http://checkip.amazonaws.com)  # 获取公网 IP
FORMATTED_IP=$(echo $SERVER_IP | tr '.' '_')      # 将点转换为下划线

# 获取容器编号，并生成唯一名称
generate_container_name() {
  local container_counter_file="/tmp/derper_counter"
  local container_id=$(cat $container_counter_file 2>/dev/null || echo 1)
  local new_counter=$((container_id + 1))
  echo $new_counter > $container_counter_file
  echo "${FORMATTED_IP}_derper$container_id"
}

# 获取容器名称
CONTAINER_NAME=$(generate_container_name)

# 6. 启动 Docker 容器并映射端口
echo "启动 Docker 容器..."

# 检查容器是否已存在，如果存在则删除
if docker ps -a --filter "name=$CONTAINER_NAME" --format "{{.Names}}"; then
  echo "容器 $CONTAINER_NAME 已存在，正在删除..."
  docker rm -f $CONTAINER_NAME  # 删除已存在的容器
fi

# 启动容器
docker run -d \
  --name $CONTAINER_NAME \
  --restart always \
  -p ${PORTS[0]}:443 \
  -p ${PORTS[1]}:3478/udp \
  -p ${PORTS[2]}:9100 \
  zhangjiayuan1983/ip_derper:latest

# 7. 检查容器状态
echo "检查容器状态..."
docker ps

# 8. 查看容器日志
echo "查看容器日志..."
docker logs $CONTAINER_NAME

# 提示用户访问服务
echo "容器已启动！您可以通过以下方式访问服务："
echo "HTTPS 服务： https://$SERVER_IP:${PORTS[0]}"
echo "STUN 服务： stun://$SERVER_IP:${PORTS[1]}"
echo "Prometheus 监控： http://$SERVER_IP:${PORTS[2]}"

echo "安装和配置完成！"
