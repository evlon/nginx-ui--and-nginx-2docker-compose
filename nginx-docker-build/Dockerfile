# 第一阶段：构建阶段
FROM alpine:latest AS builder

# 1. 配置阿里云镜像源 (替换 apk 默认源)
# Alpine 的镜像源配置文件是 /etc/apk/repositories
# 使用 sed 命令将默认源替换为阿里云镜像源
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

# 安装编译工具
RUN apk update && \
    apk add --no-cache \
    gcc \
    make \
    pcre-dev \
    zlib-dev \
    openssl-dev \
    linux-headers \
    libc-dev

# 下载并解压Nginx源码
ARG NGINX_VERSION=1.29.4
RUN wget -O nginx.tar.gz https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
    tar -xzf nginx.tar.gz && \
    rm nginx.tar.gz

# 编译安装Nginx
WORKDIR /nginx-${NGINX_VERSION}
RUN ./configure \
    --prefix=/usr/local/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx \
    --group=nginx \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_gzip_static_module \
    --with-threads \
    --with-file-aio \
    --with-stream \
    --with-stream_ssl_preread_module \
    --with-stream_ssl_module \
    --with-http_stub_status_module \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_gunzip_module \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-http_v3_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-stream_realip_module \
    --with-http_v2_module \
    --with-pcre \
    --with-pcre-jit \
    --without-http_autoindex_module && \
    make -j$(nproc) && \
    make install

# 第二阶段：运行时阶段
FROM alpine:latest

# 安装运行时依赖
RUN apk add --no-cache \
    pcre \
    zlib \
    openssl \
    tzdata && \
    addgroup -S nginx && \
    adduser -S -G nginx nginx && \
    mkdir -p /var/cache/nginx  /var/log/nginx  && \
    chown -R nginx:nginx /var/cache/nginx

# 从构建阶段复制已编译的Nginx
COPY --from=builder /usr/local/nginx /usr/local/nginx
COPY --from=builder /usr/sbin/nginx /usr/sbin/nginx
COPY --from=builder /etc/nginx /etc/nginx

# 创建必要的目录和符号链接
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

# 暴露端口
EXPOSE 80 443

# 启动命令
CMD ["nginx", "-g", "daemon off;"]