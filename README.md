docker run -d \
  --name derper1 \
  --restart always  \
  -p 34567:443 \
  -p 34568:3478/udp \
  -p 9101:9100 \
  -d zhangjiayuan1983/ip_derper

  先用dockefile自动生成一个镜像，上传到docker hub。然后在各云服务器就只需要直接下载，运用就可以。运用就是上面的代码。
