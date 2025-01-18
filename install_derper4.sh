# 4. 随机生成端口并检查端口是否被占用
echo "开始随机生成端口..."

# 随机生成端口并检查端口是否已被占用
generate_random_ports() {
  local ports=()
  for i in {1..4}; do
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
# 随机生成四个端口（从 10000 到 30000 范围内）
generate_random_port() {
  echo $((RANDOM % 20000 + 10000))
}

# 生成端口
PORTS=($(generate_random_ports))
# 检查端口是否已被占用
check_port_in_use() {
  netstat -tuln | grep ":$1" > /dev/null
  return $?
}

# 生成并显示端口
echo "随机生成的端口："
for i in {0..3}; do
  echo "容器 $((i+1)) - HTTPS 端口：${PORTS[$i]}, STUN 端口：${PORTS[$((i+1))]}, Prometheus 监控端口：${PORTS[$((i+2))]}"
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

# 5. 获取公网 IP 地址并格式化命名
SERVER_IP=$(curl -s http://checkip.amazonaws.com)  # 获取公网 IP
FORMATTED_IP=$(echo $SERVER_IP | tr '.' '_')      # 将点转换为下划线

# 获取容器编号，并生成唯一名称
generate_container_name() {
  local container_counter_file="/tmp/derper_counter_$1"
  local container_id=$(cat $container_counter_file 2>/dev/null || echo 1)
  local new_counter=$((container_id + 1))
  echo $new_counter > $container_counter_file
  echo "${FORMATTED_IP}_derper$container_id"
}
while true; do
  STUN_PORT_1=$(generate_random_port)
  check_port_in_use $STUN_PORT_1
  if [ $? -eq 1 ]; then
    break
  fi
done

# 获取容器名称
CONTAINER_NAME_1=$(generate_container_name 1)
CONTAINER_NAME_2=$(generate_container_name 2)
CONTAINER_NAME_3=$(generate_container_name 3)
CONTAINER_NAME_4=$(generate_container_name 4)
while true; do
  MONITOR_PORT_1=$(generate_random_port)
  check_port_in_use $MONITOR_PORT_1
  if [ $? -eq 1 ]; then
    break
  fi
done

# 6. 启动 4 个 Docker 容器并映射端口
echo "启动 4 个 Docker 容器..."
# 生成并检查端口 2
while true; do
  HTTPS_PORT_2=$(generate_random_port)
  check_port_in_use $HTTPS_PORT_2
  if [ $? -eq 1 ]; then
    break
  fi
done

for i in {1..4}; do
  CONTAINER_NAME_VAR="CONTAINER_NAME_$i"
  HTTPS_PORT_VAR="PORTS[$((i-1))]"
  STUN_PORT_VAR="PORTS[$((i))]"
  MONITOR_PORT_VAR="PORTS[$((i+1))]"

  # 检查容器是否已经存在
  EXISTING_CONTAINER=$(docker ps -a --filter "name=${!CONTAINER_NAME_VAR}" --format "{{.Names}}")
  if [ "$EXISTING_CONTAINER" ]; then
    echo "容器 ${!CONTAINER_NAME_VAR} 已存在，正在移除..."
    docker rm -f ${!CONTAINER_NAME_VAR}  # 强制删除已存在的容器
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

  # 启动容器
  docker run -d \
    --name ${!CONTAINER_NAME_VAR} \
    --restart always \
    -p ${!HTTPS_PORT_VAR}:443 \
    -p ${!STUN_PORT_VAR}:3478/udp \
    -p ${!MONITOR_PORT_VAR}:9100 \
    zhangjiayuan1983/ip_derper:latest

  if [ $? -ne 0 ]; then
    echo "启动容器 ${!CONTAINER_NAME_VAR} 失败！"
    docker logs ${!CONTAINER_NAME_VAR}
while true; do
  MONITOR_PORT_3=$(generate_random_port)
  check_port_in_use $MONITOR_PORT_3
  if [ $? -eq 1 ]; then
    break
fi
done

# 7. 检查容器状态
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

# 8. 查看容器日志
# 7. 查看容器日志
echo "查看容器日志..."
for i in {1..4}; do
  CONTAINER_NAME_VAR="CONTAINER_NAME_$i"
  docker logs ${!CONTAINER_NAME_VAR}
done

docker logs derper_1
docker logs derper_2
docker logs derper_3
docker logs derper_4

# 提示用户访问服务
echo "4 个容器已启动！您可以通过以下方式访问服务："
for i in {1..4}; do
  CONTAINER_NAME_VAR="CONTAINER_NAME_$i"
  HTTPS_PORT_VAR="PORTS[$((i-1))]"
  STUN_PORT_VAR="PORTS[$((i))]"
  MONITOR_PORT_VAR="PORTS[$((i+1))]"

  echo "容器 $i - HTTPS 服务： https://$SERVER_IP:${!HTTPS_PORT_VAR}"
  echo "容器 $i - STUN 服务： stun://$SERVER_IP:${!STUN_PORT_VAR}"
  echo "容器 $i - Prometheus 监控： http://$SERVER_IP:${!MONITOR_PORT_VAR}"
done
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
