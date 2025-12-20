# Nginx-UI Docker Compose 项目

一个基于 Docker Compose 的 Nginx-UI 部署方案，集成了 Nginx Web 服务器和 Nginx-UI 管理界面。

## 项目结构

```
unginx-ui--and-nginx-2docker-compose/
├── deploy/                          # 部署配置目录
│   ├── docker-compose.yml           # 生产环境 Docker Compose 配置
│   ├── data/                        # 数据持久化目录
│   │   ├── nginx_config/            # Nginx 配置文件
│   │   ├── nginx_html/              # Nginx 静态文件
│   │   ├── nginx_logs/              # Nginx 日志文件
│   │   ├── nginx_run/               # Nginx 运行时文件
│   │   └── nginx_ui_data/           # Nginx-UI 数据文件
│   ├── scripts/                     # 辅助脚本
│   │   ├── nginx-ctl.sh             # Nginx 控制脚本
│   │   ├── nginx-restart.sh         # Nginx 重启脚本
│   │   └── ps.sh                    # 进程查看脚本
│   ├── template/                    # 配置模板目录
│   └── reset-data.sh                # 数据重置脚本
├── nginx-docker-build/              # 自定义 Nginx 镜像构建目录
│   └── Dockerfile                   # Nginx 1.29.4 自定义镜像构建文件
├── nginx-ui-docker-build/           # Nginx-UI 镜像构建目录
│   ├── Dockerfile                   # Nginx-UI Docker 镜像构建文件
│   ├── docker-compose.yml          # 构建环境 Docker Compose 配置
│   ├── prepare.sh                   # Nginx-UI 下载准备脚本
│   ├── supervisord.conf            # Supervisor 配置文件
│   ├── run-logrotate.sh            # 日志轮转脚本
│   └── downloads/                   # Nginx-UI 下载文件目录
└── README.md                        # 项目说明文档
```

## 快速开始

### 1. 构建自定义 Nginx 镜像

进入 Nginx 构建目录并构建自定义镜像：

```bash
cd nginx-docker-build
docker build -t custom-nginx:1.29.4 .
```

### 2. 构建 Nginx-UI 镜像

首先进入构建目录并下载 Nginx-UI：

```bash
cd nginx-ui-docker-build
chmod +x prepare.sh
./prepare.sh
```

然后构建 Docker 镜像：

```bash
docker-compose build
```

### 2. 部署服务

进入部署目录并启动服务：

```bash
cd ../deploy
docker-compose up -d
```

### 3. 访问服务

- Nginx Web 服务：通过主机的 80/443 端口访问
- Nginx-UI 管理界面：通过主机的 9000 端口访问

## 配置说明

### 环境变量

Nginx-UI 支持以下环境变量配置：

- `NGINX_UI_SERVER_PORT`: Nginx-UI 服务端口（默认：9000）
- `NGINX_UI_SERVER_RUN_MODE`: 运行模式（debug/release）
- `NGINX_UI_NGINX_CONFIG_DIR`: Nginx 配置目录路径
- `NGINX_UI_NGINX_CONTAINER_NAME`: Nginx 容器名称
- `NGINX_UI_TERMINAL_START_CMD`: 终端启动命令（默认：bash）

### 数据持久化

项目采用数据卷持久化策略：

- `./data/nginx_config`: Nginx 配置文件
- `./data/nginx_html`: Nginx 静态文件目录
- `./data/nginx_logs`: Nginx 日志文件
- `./data/nginx_ui_data`: Nginx-UI 数据文件
- `./data/nginx_run`: Nginx 运行时文件


## 网络配置

项目使用 `network_mode: host` 模式，使容器直接使用宿主机网络，提高网络性能。

## 注意事项

1. **数据备份**: 建议定期备份 `deploy/data` 目录下的数据
2. **权限管理**: 确保 Docker 有权限访问 `/var/run/docker.sock`
3. **防火墙**: 确保 80、443、9000 端口已开放
4. **更新升级**: 重新构建镜像时记得先运行 `prepare.sh` 获取最新版本

## 故障排除

### 重置数据

如需重置所有数据：

```bash
cd deploy
chmod +x reset-data.sh
./reset-data.sh
```

### 查看日志

```bash
# 查看 Nginx-UI 日志
docker-compose logs nginx-ui

# 查看 Nginx 日志
docker-compose logs nginx-web
```

## 自定义 Nginx 镜像

### 特性

本项目包含一个自定义的 Nginx 1.29.4 Docker 镜像，具有以下特性：

- **多阶段构建**: 使用 Alpine Linux 基础镜像，优化镜像大小
- **国内镜像源**: 使用阿里云镜像源加速包下载
- **丰富模块**: 集成多种常用 Nginx 模块
- **安全配置**: 移除不必要的模块，增强安全性
- **日志优化**: 配置日志输出到标准输出/错误

### 已启用模块

**HTTP 模块**:
- `http_ssl_module` - SSL/TLS 支持
- `http_realip_module` - 获取真实客户端IP
- `http_gzip_static_module` - 静态文件压缩
- `http_stub_status_module` - 状态监控
- `http_v2_module` - HTTP/2 支持
- `http_auth_request_module` - 认证请求
- `http_dav_module` - WebDAV 支持
- `http_secure_link_module` - 安全链接
- 其他多种实用模块

**Stream 模块**:
- `stream` - TCP/UDP 代理
- `stream_ssl_module` - Stream SSL 支持
- `stream_ssl_preread_module` - SSL 预读取
- `stream_realip_module` - Stream 真实IP

**移除的模块**:
- `http_autoindex_module` - 目录列表功能（安全考虑）

### 构建配置

镜像使用以下构建参数：
- Nginx 版本：1.29.4
- 用户：nginx
- 配置路径：/etc/nginx/nginx.conf
- 日志路径：/var/log/nginx/
- PID 路径：/var/run/nginx.pid

### 使用方法

构建镜像：
```bash
cd nginx-docker-build
docker build -t custom-nginx:1.29.4 .
```

运行容器：
```bash
docker run -d -p 80:80 -p 443:443 --name nginx custom-nginx:1.29.4
```

验证版本：
```bash
docker run --rm custom-nginx:1.29.4 -V
```

## 技术栈

- **Nginx 1.29.4**: 自定义构建的高性能 Web 服务器
- **Nginx-UI**: Nginx 可视化管理界面
- **Docker**: 容器化技术
- **Docker Compose**: 容器编排工具
- **Supervisor**: 进程管理工具
- **Alpine Linux**: 轻量级基础镜像
- **GCC/Make**: 编译工具链

## 许可证

本项目遵循开源许可证。

## 贡献

欢迎提交 Issue 和 Pull Request 来改进这个项目。