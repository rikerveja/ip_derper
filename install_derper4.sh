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
        "https://docker.1ms.run",
        "https://docker.xuanyuan.me",
        "https://docker.rainbond.cc",
        "https://do.nark.eu.org",
        "https://dc.j8.work"
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

# 随机生成四个端口（从 10000 到 30000 范围内）
generate_random_port() {
  echo $((RANDOM % 20000 + 10000))
}

# 检查端口是否已被占用
check_port_in_use() {
  netstat -tuln | grep ":$1" > /dev/null
  return $?
}

# 生成并检查端口是否被占用，直到找到可用端口
HTTPS_PORT_1=0
STUN_PORT_1=0
MONITOR_PORT_1=0

HTTPS_PORT_2=0
STUN_PORT_2=0
MONITOR_PORT_2=0

HTTPS_PORT_3=0
STUN_PORT_3=0
MONITOR_PORT_3=0

HTTPS_PORT_4=0
STUN_PORT_4=0
MONITOR_PORT_4=0

# 生成并检查端口 1
while true; do
  HTTPS_PORT_1=$(generate_random_port)
  check_port_in_use $HTTPS_PORT_1
  if [ $? -eq 1 ]; then
    break
  fi
done

while true; do
  STUN_PORT_1=$(generate_random_port)
  check_port_in_use $STUN_PORT_1
  if [ $? -eq 1 ]; then
    break
  fi
done

while true; do
  MONITOR_PORT_1=$(generate_random_port)
  check_port_in_use $MONITOR_PORT_1
  if [ $? -eq 1 ]; then
    break
  fi
done

# 生成并检查端口 2
while true; do
  HTTPS_PORT_2=$(generate_random_port)
  check_port_in_use $HTTPS_PORT_2
  if [ $? -eq 1 ]; then
    break
  fi
done

while true; do
  STUN_PORT_2=$(generate_random_port)
  check_port_in_use $STUN_PORT_2
  if [ $? -eq 1 ]; then
    break
  fi
done

while true; do
  MONITOR_PORT_2=$(generate_random_port)
  check_port_in_use $MONITOR_PORT_2
  if [ $? -eq 1 ]; then
    break
  fi
done

# 生成并检查端口 3
while true; do
  HTTPS_PORT_3=$(generate_random_port)
  check_port_in_use $HTTPS_PORT_3
  if [ $? -eq 1 ]; then
    break
  fi
done

while true; do
  STUN_PORT_3=$(generate_random_port)
  check_port_in_use $STUN_PORT_3
  if [ $? -eq 1 ]; then
    break
  fi
done

while true; do
  MONITOR_PORT_3=$(generate_random_port)
  check_port_in_use $MONITOR_PORT_3
  if [ $? -eq 1 ]; then
    break
  fi
done

# 生成并检查端口 4
while true; do
  HTTPS_PORT_4=$(generate_random_port)
  check_port_in_use $HTTPS_PORT_4
  if [ $? -eq 1 ]; then
    break
  fi
done

while true; do
  STUN_PORT_4=$(generate_random_port)
  check_port_in_use $STUN_PORT_4
  if [ $? -eq 1 ]; then
    break
  fi
done

while true; do
  MONITOR_PORT_4=$(generate_random_port)
  check_port_in_use $MONITOR_PORT_4
  if [ $? -eq 1 ]; then
    break
  fi
done

echo "随机生成的端口："
echo "容器 1 - HTTPS 端口：$HTTPS_PORT_1, STUN 端口：$STUN_PORT_1, Prometheus 监控端口：$MONITOR_PORT_1"
echo "容器 2 - HTTPS 端口：$HTTPS_PORT_2, STUN 端口：$STUN_PORT_2, Prometheus 监控端口：$MONITOR_PORT_2"
echo "容器 3 - HTTPS 端口：$HTTPS_PORT_3, STUN 端口：$STUN_PORT_3, Prometheus 监控端口：$MONITOR_PORT_3"
echo "容器 4 - HTTPS 端口：$HTTPS_PORT_4, STUN 端口：$STUN_PORT_4, Prometheus 监控端口：$MONITOR_PORT_4"

# 5. 启动 4 个 Docker 容器并映射端口
echo "启动 4 个 Docker 容器..."

docker run -d \
  --name derper_1 \
  --restart always \
  -p $HTTPS_PORT_1:443 \
  -p $STUN_PORT_1:3478/udp \
  -p $MONITOR_PORT_1:9100 \
  zhangjiayuan1983/ip_derper:latest

docker run -d \
  --name derper_2 \
  --restart always \
  -p $HTTPS_PORT_2:443 \
  -p $STUN_PORT_2:3478/udp \
  -p $MONITOR_PORT_2:9100 \
  zhangjiayuan1983/ip_derper:latest

docker run -d \
  --name derper_3 \
  --restart always \
  -p $HTTPS_PORT_3:443 \
  -p $STUN_PORT_3:3478/udp \
  -p $MONITOR_PORT_3:9100 \
  zhangjiayuan1983/ip_derper:latest

docker run -d \
  --name derper_4 \
  --restart always \
  -p $HTTPS_PORT_4:443 \
  -p $STUN_PORT_4:3478/udp \
  -p $MONITOR_PORT_4:9100 \
  zhangjiayuan1983/ip_derper:latest

# 6. 检查容器状态
echo "检查容器状态..."

docker ps

# 7. 查看容器日志
echo "查看容器日志..."

docker logs derper_1
docker logs derper_2
docker logs derper_3
docker logs derper_4

# 提示用户访问服务
echo "4 个容器已启动！您可以通过以下方式访问服务："
echo "容器 1 - HTTPS 服务： https://<your-server-ip>:$HTTPS_PORT_1"
echo "容器 1 - STUN 服务： stun://<your-server-ip>:$STUN_PORT_1"
echo "容器 1 - Prometheus 监控： http://<your-server-ip>:$MONITOR_PORT_1"

echo "容器 2 - HTTPS 服务： https://<your-server-ip>:$HTTPS_PORT_2"
echo "容器 2 - STUN 服务： stun://<your-server-ip>:$STUN_PORT_2"
echo "容器 2 - Prometheus 监控： http://<your-server-ip>:$MONITOR_PORT_2"

echo "容器 3 - HTTPS 服务： https://<your-server-ip>:$HTTPS_PORT_3"
echo "容器 3 - STUN 服务： stun://<your-server-ip>:$STUN_PORT_3"
echo "容器 3 - Prometheus 监控： http://<your-server-ip>:$MONITOR_PORT_3"

echo "容器 4 - HTTPS 服务： https://<your-server-ip>:$HTTPS_PORT_4"
echo "容器 4 - STUN 服务： stun://<your-server-ip>:$STUN_PORT_4"
echo "容器 4 - Prometheus 监控： http://<your-server-ip>:$MONITOR_PORT_4"

echo "安装和配置完成！"
