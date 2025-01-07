# 第一阶段：构建阶段
FROM golang:latest AS builder

LABEL org.opencontainers.image.source https://github.com/yangchuansheng/ip_derper

WORKDIR /app

# 将项目代码添加到容器中
ADD . /app

# 安装依赖并构建项目
RUN cd /app/cmd/derper && \
    go mod tidy && \
    CGO_ENABLED=0 go build -ldflags="-s -w" -o /app/derper

# 第二阶段：运行阶段
FROM ubuntu:20.04

# 安装基础依赖
RUN apt-get update && apt-get install -y \
    openssl \
    curl \
    bash && \
    rm -rf /var/lib/apt/lists/*

# 尝试通过 apt-get 安装 node-exporter，失败时使用手动安装方式
RUN apt-get update && apt-get install -y node-exporter || \
    (echo "apt-get install node-exporter failed, falling back to manual installation" && \
    curl -LO https://ghproxy.cc/https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz && \
    tar xvfz node_exporter-*.tar.gz && \
    mv node_exporter-*/node_exporter /usr/local/bin/)

# 设置工作目录
WORKDIR /app

# 将构建好的 derper 二进制文件从构建阶段复制到最终镜像
COPY --from=builder /app/derper /app/derper

# 拷贝证书生成脚本和配置文件
COPY build_cert.sh /app/
COPY san.conf /app/san.conf

# ========== CONFIG =========
# 配置环境变量
ENV DERP_ADDR :443
ENV DERP_HTTP_PORT 80
ENV DERP_HOST=127.0.0.1
ENV DERP_CERTS=/app/certs/
ENV DERP_STUN true
ENV DERP_VERIFY_CLIENTS false
# ==========================

# 暴露服务端口
EXPOSE 443 80 9100

# 启动 node-exporter 和 derper 服务
CMD bash /app/build_cert.sh $DERP_HOST $DERP_CERTS /app/san.conf && \
    /app/derper --hostname=$DERP_HOST \
    --certmode=manual \
    --certdir=$DERP_CERTS \
    --stun=$DERP_STUN  \
    --a=$DERP_ADDR \
    --http-port=$DERP_HTTP_PORT \
    --verify-clients=$DERP_VERIFY_CLIENTS & \
    /usr/local/bin/node_exporter --web.listen-address=":9100"
