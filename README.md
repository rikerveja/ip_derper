全自动封装在了install_derper.sh


chmod +x install_derper.sh

./install_derper.sh





好的！下面我将一步步指导您从 **安装 Docker CE** 开始，直到 **使用 `docker run` 启动 `derper` 服务**。

### **步骤 1：安装 Docker CE（Community Edition）**

首先，您需要在服务器上安装 **Docker CE**。

#### 1.1. **卸载旧版本的 Docker（如果有）**

如果系统上已经安装了 Docker，先卸载旧版本的 Docker：

```bash
sudo apt-get remove docker docker-engine docker.io containerd runc
```

#### 1.2. **更新 apt 包索引**

确保您的包管理工具是最新的：

```bash
sudo apt-get update
```

#### 1.3. **安装必要的依赖**

安装 Docker 需要一些依赖包，这些包用于允许 apt 使用 HTTPS 下载 Docker 包：

```bash
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
```

#### 1.4. **添加 Docker 官方 GPG 密钥**

使用以下命令添加 Docker 官方的 GPG 密钥，以确保下载的 Docker 包是官方的：

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```

#### 1.5. **添加 Docker 仓库**

添加 Docker 官方的 APT 仓库源：

```bash
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
```

#### 1.6. **安装 Docker CE**

更新 apt 包索引，并安装 Docker CE：

```bash
sudo apt-get update
sudo apt-get install docker-ce
```

#### 1.7. **启动并验证 Docker**

启动 Docker 服务，并检查 Docker 是否正确安装：

```bash
sudo systemctl start docker
sudo systemctl enable docker  # 设置 Docker 开机自启
sudo systemctl status docker  # 检查 Docker 服务状态
```

验证 Docker 是否正确安装：

```bash
docker --version
```

您应该看到类似下面的输出，表明 Docker 已安装并正在运行：

```bash
Docker version 20.10.7, build f0df350
```

#### 1.8. **配置 Docker 权限（可选）**

为了避免每次使用 Docker 命令时都需要加上 `sudo`，您可以将当前用户添加到 Docker 组：

```bash
sudo usermod -aG docker $USER
```

运行完这个命令后，您需要退出当前终端会话并重新登录，或者运行以下命令使更改立即生效：

```bash
newgrp docker
```
配置 Docker Daemon
Linux
Windows
macOS
1. 编辑 /etc/docker/daemon.json 文件：


{
  "registry-mirrors": [
    "https://docker.imgdb.de"
  ]
}
2. 重启 Docker 服务：


sudo systemctl restart docker
### **步骤 2：下载 `zhangjiayuan1983/ip_derper` 镜像**

#### 2.1. **拉取镜像**

现在您可以从 Docker Hub 拉取 **`zhangjiayuan1983/ip_derper:latest`** 镜像了：

```bash
docker pull zhangjiayuan1983/ip_derper:latest
```

#### 2.2. **检查镜像是否成功拉取**

检查镜像是否已成功下载：

```bash
docker images
```

您应该能看到类似这样的输出，确认镜像已经下载：

```
REPOSITORY                     TAG       IMAGE ID       CREATED         SIZE
zhangjiayuan1983/ip_derper      latest    f9a8a1b29009   2 days ago      500MB
```

### **步骤 3：使用 `docker run` 启动 `derper` 服务**

#### 3.1. **运行 `derper` 服务容器**

使用以下命令启动 `derper` 服务容器：

```bash
docker run -d \
  --name derper \
  --restart always \
  -p 34567:443 \
  -p 34568:3478/udp \
  -p 9100:9100 \
  zhangjiayuan1983/ip_derper:latest
```

解释每个选项的含义：
- **`-d`**：后台运行容器。
- **`--name derper`**：为容器指定名称为 `derper`。
- **`--restart always`**：确保容器在系统重启后自动重启。
- **`-p 34567:443`**：将宿主机的端口 **34567** 映射到容器的 **443** 端口，用于 **HTTPS**。
- **`-p 34568:3478/udp`**：将宿主机的端口 **34568** 映射到容器的 **3478/udp** 端口，用于 **STUN**。
- **`-p 9100:9100`**：将宿主机的端口 **9100** 映射到容器的 **9100** 端口，用于 **`node-exporter`** 服务。

#### 3.2. **验证容器是否正常运行**

检查容器是否成功启动：

```bash
docker ps
```

您应该看到类似以下的输出，表示容器正在运行：

```
CONTAINER ID   IMAGE                                  COMMAND                  CREATED         STATUS         PORTS                                                                                       NAMES
abcd1234efgh   zhangjiayuan1983/ip_derper:latest    "/bin/sh -c 'node_ex…"   2 seconds ago   Up 1 second    0.0.0.0:34567->443/tcp, 0.0.0.0:34568->3478/udp, 0.0.0.0:9100->9100/tcp                    derper
```

#### 3.3. **查看容器日志**

如果容器没有启动，您可以查看容器的日志来进行调试：

```bash
docker logs derper
```

日志会帮助您了解容器启动过程中出现的任何错误或警告。

### **步骤 4：验证 `derper` 服务**

现在，您可以通过浏览器或 `curl` 访问 **`derper`** 服务来验证其是否正常运行：

- **访问 HTTPS 服务**（`derp` 服务）：`https://<your-server-ip>:34567`
- **访问 STUN 服务**：`stun://<your-server-ip>:34568`
- **访问 `node-exporter`**：`http://<your-server-ip>:9100`

### **总结**

通过这些步骤，您应该能够：
1. 安装 **Docker CE** 并启动 **Docker** 服务。
2. 从 **Docker Hub** 拉取 **`zhangjiayuan1983/ip_derper:latest`** 镜像。
3. 使用 **`docker run`** 启动 `derper` 服务容器，并映射相关端口。
4. 验证容器是否正常运行，并确保服务可访问。

如果有任何问题，或者在执行过程中遇到困难，请随时告诉我！



docker run -d \
  --name derper \
  --restart always \
  -p 34567:443 \
  -p 34568:3478/udp \
  -p 9100:9100 \
  zhangjiayuan1983/ip_derper:latest

  先用dockefile自动生成一个镜像，上传到docker hub。然后在各云服务器就只需要直接下载，运用就可以。运用就是上面的代码。
