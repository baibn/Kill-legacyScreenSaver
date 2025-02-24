#!/bin/bash

# 设置内存使用限额（单位：MB）
MEMORY_LIMIT=100  # 0.1GB

# 获取脚本的执行路径
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="$SCRIPT_DIR/legacyScreenSaver_memory_monitor.log"

# 获取当前时间的函数
get_current_time() {
    echo "$(date '+%Y-%m-%d %H:%M:%S')"  # 格式化时间为 YYYY-MM-DD HH:MM:SS
}

# 检查并终止进程的函数
check_and_kill_process() {
    # 使用 pgrep 检查 legacyScreenSaver-x86_64 进程是否存在
    local pid=$(pgrep -f legacyScreenSaver-x86_64)
    local status=$?

    if [[ $status -ne 0 || -z "$pid" ]]; then  # 如果 pgrep 返回非零值或 PID 为空
        echo "$(get_current_time) - legacyScreenSaver-x86_64 进程未运行。" >> "$LOG_FILE"
        return
    fi

    # 获取该进程的内存使用情况（单位：MB）
    local memory_usage=$(ps -o rss= -p "$pid")
    if [[ -z "$memory_usage" ]]; then  # 如果没有获取到内存使用信息
        echo "$(get_current_time) - 无法获取 legacyScreenSaver-x86_64 (PID: $pid) 的内存使用信息。" >> "$LOG_FILE"
        return
    fi

    memory_usage=$((memory_usage / 1024))  # 转换为 MB

    # 检查内存使用是否超过限额
    if [[ "$memory_usage" -ge "$MEMORY_LIMIT" ]]; then
        echo "$(get_current_time) - legacyScreenSaver-x86_64 (PID: $pid) 内存占用过高 ($memory_usage MB)，正在终止进程。" >> "$LOG_FILE"
        kill -9 "$pid"  # 强制终止进程
    else
        echo "$(get_current_time) - legacyScreenSaver-x86_64 (PID: $pid) 内存占用正常 ($memory_usage MB)。" >> "$LOG_FILE"
    fi
}

# 主函数
check_and_kill_process
