#!/bin/sh
CONTAINER="${NGINX_UI_NGINX_CONTAINER_NAME:?need container name}"
curl -sS -X POST --unix-socket /var/run/docker.sock \
  -H "Content-Type: application/json" \
  -d '{"t":10}' \
  "http://localhost/containers/${CONTAINER}/restart"