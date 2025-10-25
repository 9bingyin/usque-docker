FROM alpine:latest AS downloader

ARG TARGETARCH
ARG VERSION

WORKDIR /tmp

# 安装下载工具
RUN apk --no-cache add wget unzip

# 下载并解压对应架构的二进制文件
RUN DOWNLOAD_URL="https://github.com/Diniboy1123/usque/releases/download/${VERSION}/usque_${VERSION#v}_linux_${TARGETARCH}.zip" && \
    echo "下载地址: ${DOWNLOAD_URL}" && \
    wget -O usque.zip "${DOWNLOAD_URL}" && \
    unzip usque.zip && \
    chmod +x usque

# 最终镜像
FROM alpine:latest

# 安装必要的工具
# ca-certificates: 支持 HTTPS
# curl: 健康检查使用
RUN apk --no-cache add ca-certificates curl

WORKDIR /app

# 从下载阶段复制二进制文件
COPY --from=downloader /tmp/usque /bin/usque

# 复制启动脚本和健康检查脚本
COPY entrypoint.sh /entrypoint.sh
COPY healthcheck.sh /healthcheck.sh
RUN chmod +x /entrypoint.sh /healthcheck.sh

# 暴露默认端口（默认监听 127.0.0.1:1080，可通过环境变量修改）
# 支持的环境变量：
#   SOCKS_BIND: 监听地址（默认 127.0.0.1）
#   SOCKS_PORT: 监听端口（默认 1080）
#   SOCKS_USER: SOCKS5 用户名（可选）
#   SOCKS_PASS: SOCKS5 密码（可选）
EXPOSE 1080

# 健康检查
# 间隔 30 秒检查一次，超时 10 秒，启动后 10 秒开始第一次检查，连续失败 3 次判定为不健康
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD ["/healthcheck.sh"]

# 设置入口点
ENTRYPOINT ["/entrypoint.sh"]
