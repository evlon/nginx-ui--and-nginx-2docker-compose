# ----------------------------------------------------
# 阶段 0: 核心依赖和运维工具 (基于 Alpine，最小化)
# ----------------------------------------------------
FROM alpine:latest AS base-tools

ENV NGINX_UI_PORT=8080

# 1. 配置清华大学 TUNA 镜像源 (替换 apk 默认源)
# Alpine 的镜像源配置文件是 /etc/apk/repositories
# 使用 sed 命令将默认源替换为 TUNA 镜像源
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

# 2. 安装核心依赖和运维工具 (从清华源下载)
# --no-cache: 保持镜像最小，不保留索引文件
# tzdata: 时区数据
# supervisor: 进程管理器
# logrotate: 日志滚动工具
# bash, procps, bind-tools, net-tools, vim, less, rsync: 运维常用工具
RUN apk update && \
    apk add --no-cache \
    supervisor \
    logrotate \
    openrc \
    curl \
    gzip \
    tar \
    git \
    tzdata \
    # 运维工具增强
    bash \
    procps \
    bind-tools \
    net-tools \
    vim \
    less \
    rsync \
    # 清理 apk 缓存
    && rm -rf /var/cache/apk/*

# ----------------------------------------------------
# 阶段 1: 运行镜像构建 (Nginx-UI 拷贝与安装 - 最容易变动)
# ----------------------------------------------------
FROM base-tools AS final

# 1. Nginx-UI 拷贝
# 注意：确保宿主机已通过 prepare.sh 下载了该文件 (.tar.gz)
COPY downloads/nginx-ui-linux-64.tar.gz /tmp/nginx-ui.tar.gz

# 2. 安装 Nginx-UI
RUN mkdir -p /opt/nginx-ui && \
    # 解压到 /opt/nginx-ui 目录
    tar -xzf /tmp/nginx-ui.tar.gz -C /opt/nginx-ui && \
    rm /tmp/nginx-ui.tar.gz && \
    chmod +x /opt/nginx-ui/nginx-ui

# 3. 复制 Supervisor 配置文件 (需要确保 supervisord.conf 兼容 Alpine)
# Supervisor 在 Alpine 上通常可以直接使用
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 4. 暴露端口并设置启动命令
EXPOSE 80 443 8080 9000
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]