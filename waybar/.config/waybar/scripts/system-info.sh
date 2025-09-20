#!/bin/bash

# System monitoring script for Waybar
# Shows CPU, memory, and disk usage with proper formatting

get_cpu_usage() {
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | awk -F'%' '{print $1}')
    echo "${cpu_usage}%"
}

get_memory_usage() {
    memory_info=$(free -m | awk 'NR==2{printf "%.0f%%", $3*100/$2}')
    echo "$memory_info"
}

get_disk_usage() {
    disk_usage=$(df -h / | awk 'NR==2{print $5}')
    echo "$disk_usage"
}

# Get system load average
load_avg=$(uptime | awk -F'load average:' '{ print $2 }' | awk '{ print $1 }' | sed 's/,//')

case "$1" in
    "cpu")
        cpu=$(get_cpu_usage)
        echo "{\"text\": \"󰍛 $cpu\", \"tooltip\": \"CPU Usage: $cpu\\nLoad Average: $load_avg\"}"
        ;;
    "memory")
        memory=$(get_memory_usage)
        memory_details=$(free -h | awk 'NR==2{printf "Used: %s / %s", $3, $2}')
        echo "{\"text\": \" $memory\", \"tooltip\": \"Memory Usage: $memory\\n$memory_details\"}"
        ;;
    "disk")
        disk=$(get_disk_usage)
        disk_details=$(df -h / | awk 'NR==2{printf "Used: %s / %s\\nAvailable: %s", $3, $2, $4}')
        echo "{\"text\": \"󰆼 $disk\", \"tooltip\": \"Disk Usage: $disk\\n$disk_details\"}"
        ;;
    *)
        echo "{\"text\": \"  System\", \"tooltip\": \"Click to view system info\"}"
        ;;
esac
