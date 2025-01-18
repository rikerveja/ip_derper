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
# 随机生成三个端口（从 10000 到 30000 范围内）
generate_random_port() {
  echo $((RANDOM % 20000 + 10000))
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
# 检查端口是否已被占用
check_port_in_use() {
  netstat -tuln | grep ":$1" > /dev/null
  return $?
}

# 获取容器名称
CONTAINER_NAME=$(generate_container_name)
# 生成并检查端口是否被占用，直到找到可用端口
HTTPS_PORT=0
STUN_PORT=0
MONITOR_PORT=0

while true; do
  HTTPS_PORT=$(generate_random_port)
  check_port_in_use $HTTPS_PORT
  if [ $? -eq 1 ]; then
    break
  fi
done

while true; do
  STUN_PORT=$(generate_random_port)
  check_port_in_use $STUN_PORT
  if [ $? -eq 1 ]; then
    break
  fi
done

while true; do
  MONITOR_PORT=$(generate_random_port)
  check_port_in_use $MONITOR_PORT
  if [ $? -eq 1 ]; then
    break
  fi
done

# 6. 启动 Docker 容器并映射端口
echo "启动 Docker 容器..."
echo "随机生成的端口："
echo "HTTPS 端口：$HTTPS_PORT"
echo "STUN 端口：$STUN_PORT"
echo "Prometheus 监控端口：$MONITOR_PORT"

# 检查容器是否已存在，如果存在则删除
if docker ps -a --filter "name=$CONTAINER_NAME" --format "{{.Names}}"; then
  echo "容器 $CONTAINER_NAME 已存在，正在删除..."
  docker rm -f $CONTAINER_NAME  # 删除已存在的容器
fi
# 5. 启动 Docker 容器并映射端口
echo "启动 Docker 容器..."

# 启动容器
docker run -d \
  --name $CONTAINER_NAME \
  --name derper \
--restart always \
  -p ${PORTS[0]}:443 \
  -p ${PORTS[1]}:3478/udp \
  -p ${PORTS[2]}:9100 \
  -p $HTTPS_PORT:443 \
  -p $STUN_PORT:3478/udp \
  -p $MONITOR_PORT:9100 \
zhangjiayuan1983/ip_derper:latest

# 7. 检查容器状态
# 6. 检查容器状态
echo "检查容器状态..."

docker ps

# 8. 查看容器日志
# 7. 查看容器日志
echo "查看容器日志..."
docker logs $CONTAINER_NAME

docker logs derper

# 提示用户访问服务
echo "容器已启动！您可以通过以下方式访问服务："
echo "HTTPS 服务： https://$SERVER_IP:${PORTS[0]}"
echo "STUN 服务： stun://$SERVER_IP:${PORTS[1]}"
echo "Prometheus 监控： http://$SERVER_IP:${PORTS[2]}"
echo "HTTPS 服务： https://<your-server-ip>:$HTTPS_PORT"
echo "STUN 服务： stun://<your-server-ip>:$STUN_PORT"
echo "Prometheus 监控： http://<your-server-ip>:$MONITOR_PORT"

echo "安装和配置完成！"
