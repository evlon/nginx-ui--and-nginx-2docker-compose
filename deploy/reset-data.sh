#!/bin/sh
rm -rf ./data/*
mkdir ./template/{nginx_run,nginx_logs,nginx_config,nginx_ui_data} ./data/
cp -r template/* ./data/