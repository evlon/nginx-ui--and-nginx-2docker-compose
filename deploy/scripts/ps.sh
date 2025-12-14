#!/bin/bash

echo "USER       PID  %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND"

for pid in $(ls /proc | grep -E '^[0-9]+$' | sort -n); do
    if [ -f "/proc/$pid/stat" ] && [ -f "/proc/$pid/status" ]; then
        # 从stat文件读取
        read -r pid_num comm state ppid pgrp session tty_nr tpgid flags < \
            <(cat "/proc/$pid/stat" 2>/dev/null) || continue
        
        # 从status文件读取
        uid=$(grep '^Uid:' "/proc/$pid/status" | awk '{print $2}')
        user=$(getent passwd "$uid" | cut -d: -f1 2>/dev/null || echo "$uid")
        
        vsize=$(grep '^VmSize:' "/proc/$pid/status" | awk '{print $2}' || echo 0)
        rss=$(grep '^VmRSS:' "/proc/$pid/status" | awk '{print $2}' || echo 0)
        
        # CPU时间计算 - 使用bc处理浮点数
        if [ -f "/proc/uptime" ]; then
            uptime=$(awk '{print $1}' /proc/uptime)
            start_time=$(awk '{print $22}' "/proc/$pid/stat" 2>/dev/null || echo 0)
            hertz=$(getconf CLK_TCK 2>/dev/null || echo 100)
            
            if [ "$start_time" -gt 0 ]; then
                # 使用bc进行浮点数计算
                seconds=$(echo "$uptime - $start_time / $hertz" | bc 2>/dev/null || echo 0)
                # 转换为整数秒
                seconds_int=$(printf "%.0f" "$seconds" 2>/dev/null || echo 0)
                time_str=$(printf "%02d:%02d" $((seconds_int/60)) $((seconds_int%60)))
            else
                time_str="00:00"
            fi
        else
            time_str="00:00"
        fi
        
        # 命令行
        if [ -f "/proc/$pid/cmdline" ]; then
            cmd=$(tr '\0' ' ' < "/proc/$pid/cmdline" | head -c 50)
            [ -z "$cmd" ] && cmd="[$(grep '^Name:' "/proc/$pid/status" | awk '{print $2}')]"
        else
            cmd="[unknown]"
        fi
        
        printf "%-8s %6s %4s %4s %7s %6s %-8s %-4s %5s %s\n" \
            "$user" "$pid_num" "0.0" "0.0" "$vsize" "$rss" "?" "$state" "$time_str" "$cmd"
    fi
done