#!/bin/bash

# 获取当前最大的容器编号
get_max_container_number() {
  local max_num=0
  for name in $(docker ps -a --format "{{.Names}}" | grep -oP 'derper_\d+' | grep -oP '\d+'); do
    if [ "$name" -gt "$max_num" ]; then
      max_num=$name
    fi
  done
  echo "$max_num"
}

# 生成随机端口并确保端口可用
generate_random_port() {
  local port=0
  while true; do
    port=$((RANDOM % 20000 + 10000))
    if ! netstat -tuln | grep -q ":$port"; then
      break
    fi
  done
  echo "$port"
}

# 计算新的容器编号
start_num=$(($(get_max_container_number) + 1))
end_num=$((start_num + 3))

# 逐个创建新容器
for ((i = start_num; i <= end_num; i++)); do
  HTTPS_PORT=$(generate_random_port)
  STUN_PORT=$(generate_random_port)
  MONITOR_PORT=$(generate_random_port)
  
  docker run -d \
    --name derper_$i \
    --restart always \
    -p $HTTPS_PORT:443 \
    -p $STUN_PORT:3478/udp \
    -p $MONITOR_PORT:9100 \
    zhangjiayuan1983/ip_derper:latest

  echo "容器 $i 启动完成: HTTPS端口=$HTTPS_PORT, STUN端口=$STUN_PORT, 监控端口=$MONITOR_PORT"
done

echo "所有新的 $((end_num - start_num + 1)) 个容器已启动！"

docker ps
