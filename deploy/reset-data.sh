#!/bin/sh
rm -rf ./data
mkdir -p ./data
mkdir -p ./data/nginx_run ./data/nginx_logs ./data/nginx_config ./data/nginx_ui_data
cp -r template/* ./data/