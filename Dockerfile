# 第一阶段：构建阶段
FROM golang:latest AS builder

LABEL org.opencontainers.image.source https://github.com/yangchuansheng/ip_derper

WORKDIR /app

# 使用 Go 镜像代理来加速模块下载
ENV GOPROXY=https://goproxy.cn,direct

# 将项目代码添加到容器中
ADD tailscale /app/tailscale

# 编译修改后的 derper
RUN cd /app/tailscale/cmd/derper && \
    CGO_ENABLED=0 /usr/local/go/bin/go build -buildvcs=false -ldflags "-s -w" -o /app/derper && \
    cd /app && \
    rm -rf /app/tailscale

# 第二阶段：运行阶段
FROM ubuntu:20.04

WORKDIR /app

# ========== CONFIG =========
# 配置环境变量
ENV DERP_ADDR :443
ENV DERP_HTTP_PORT 80
ENV DERP_HOST=127.0.0.1
ENV DERP_CERTS=/app/certs/
ENV DERP_STUN true
ENV DERP_VERIFY_CLIENTS false
# ==========================

# 安装基本依赖和 curl
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

# 拷贝证书生成脚本和配置文件
COPY build_cert.sh /app/
COPY --from=builder /app/derper /app/derper

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
