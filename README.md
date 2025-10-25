# Usque Docker

[![Build and Push Docker Image](https://github.com/9bingyin/usque-docker/actions/workflows/docker-build.yml/badge.svg)](https://github.com/9bingyin/usque-docker/actions/workflows/docker-build.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/9bingyin/usque-docker)](https://github.com/9bingyin/usque-docker/pkgs/container/usque-docker)

基于 [Diniboy1123/usque](https://github.com/Diniboy1123/usque) 的 Docker 镜像，提供开箱即用的 Cloudflare WARP MASQUE 协议代理服务。

## 快速开始

### 默认配置启动

```bash
docker run -d \
  --name usque \
  --network host \
  -v ~/usque-config:/app \
  ghcr.io/9bingyin/usque-docker:latest
```

默认配置：
- 监听地址：`127.0.0.1:1080`
- 模式：SOCKS5 代理
- 认证：未启用

### 测试连接

```bash
curl -x socks5://127.0.0.1:1080 https://cloudflare.com/cdn-cgi/trace
```

## 环境变量

| 变量名 | 说明 | 默认值 | 示例 |
|--------|------|--------|------|
| `SOCKS_BIND` | 监听地址 | `127.0.0.1` | `0.0.0.0` |
| `SOCKS_PORT` | 监听端口 | `1080` | `8080` |
| `SOCKS_USER` | SOCKS5 用户名（可选） | - | `admin` |
| `SOCKS_PASS` | SOCKS5 密码（可选） | - | `secret123` |