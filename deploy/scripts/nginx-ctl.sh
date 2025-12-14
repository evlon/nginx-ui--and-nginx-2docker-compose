#!/bin/sh
 
# 目的	NGINX 信号/命令	传递给脚本的参数
# 测试配置 (Test Config)	        nginx -t	        test
# 重载配置 (Reload Config)	        nginx -s reload	    reload
# 优雅地停止 (Graceful Shutdown)	nginx -s quit	     quit
# 快速关闭 (Fast Shutdown)	        nginx -s stop	    stop
# 重新打开日志文件 (Reopen Logs)	 nginx -s reopen	  reopen

set -e
CONTAINER="${NGINX_UI_CRI_NGINX_CONTAINER_NAME:?need container name}"

# 1. 检查是否提供了操作参数
if [ -z "$1" ]; then
    echo "Usage: $0 <nginx_command>"
    echo "Example: $0 reload"
    exit 1
fi

NGINX_COMMAND="$1"
EXEC_CMD=""

if [ "$NGINX_COMMAND" = "test" ]; then
    # 对于 'test'，命令是 ["nginx", "-t"]
    EXEC_CMD='["nginx", "-t"]'
elif [ "$NGINX_COMMAND" = "reload" ] || [ "$NGINX_COMMAND" = "quit" ] || [ "$NGINX_COMMAND" = "stop" ] || [ "$NGINX_COMMAND" = "reopen" ]; then
    # 对于其他信号，命令是 ["nginx", "-s", "<signal>"]
    EXEC_CMD=$(printf '["nginx","-s","%s"]' "$NGINX_COMMAND")
else
    echo "Unsupported NGINX command: $NGINX_COMMAND"
    exit 1
fi

# 构建完整的 JSON 数据
# 注意：这里我们使用 $EXEC_CMD 变量
JSON_DATA=$(printf '{"AttachStdin":false,"AttachStdout":true,"AttachStderr":true,"Cmd":%s}' "$EXEC_CMD")

# 创建 exec 实例
EXEC_ID=$(curl -sS -X POST --unix-socket /var/run/docker.sock \
  -H "Content-Type: application/json" \
  -d "$JSON_DATA" \
  "http://localhost/containers/${CONTAINER}/exec" \
  | sed -n 's/.*"Id":"\([^"]*\)".*/\1/p')

# 启动并回显
curl -sS -X POST --unix-socket /var/run/docker.sock \
  -H "Content-Type: application/json" \
  -d '{"Detach":false,"Tty":false}' \
  "http://localhost/exec/${EXEC_ID}/start"