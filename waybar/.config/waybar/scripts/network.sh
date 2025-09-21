#!/bin/bash

# Network monitoring script for Waybar
# Shows network status, IP, and connection info

# Function to get active network interface
get_active_interface() {
    ip route | grep '^default' | awk '{print $5}' | head -1
}

# Function to check if connected to internet
check_internet() {
    ping -c 1 -W 2 8.8.8.8 &>/dev/null
    return $?
}

# Function to get network speed (requires vnstat, optional)
get_network_speed() {
    if command -v vnstat &> /dev/null; then
        vnstat -i "$1" --json | jq -r '.interfaces[0].traffic.day[-1].tx' 2>/dev/null || echo "N/A"
    else
        echo "N/A"
    fi
}

# Get active interface
interface=$(get_active_interface)

if [[ -z "$interface" ]]; then
    echo '{"text": " Disconnected", "class": "disconnected", "tooltip": "No network connection"}'
    exit 0
fi

# Get IP address
ip_addr=$(ip addr show "$interface" | grep 'inet ' | awk '{print $2}' | cut -d/ -f1 | head -1)

# Check connection type and set icon
if [[ "$interface" =~ ^wl ]]; then
    # WiFi interface
    if command -v iwgetid &> /dev/null; then
        ssid=$(iwgetid -r 2>/dev/null)
        signal=$(cat /proc/net/wireless | grep "$interface" | awk '{print int($3 * 70 / 70)}' 2>/dev/null)
        if [[ $signal -gt 80 ]]; then
            icon=""
        elif [[ $signal -gt 60 ]]; then
            icon=""
        elif [[ $signal -gt 40 ]]; then
            icon=""
        elif [[ $signal -gt 20 ]]; then
            icon=""
        else
            icon=""
        fi
        connection_type="WiFi"
        connection_info="SSID: $ssid\nSignal: ${signal}%"
    else
        icon=""
        connection_type="WiFi"
        connection_info="WiFi Connected"
    fi
else
    # Wired interface
    icon="󰈀"
    connection_type="Ethernet"
    connection_info="Wired Connection"
fi

# Check internet connectivity
if check_internet; then
    class="connected"
    status="Connected"
else
    class="limited"
    status="Limited"
    icon=""
fi

# Build tooltip
tooltip="$connection_type - $status\n$connection_info\nIP: $ip_addr\nInterface: $interface"

# Output JSON
echo "{\"text\": \"$icon\", \"class\": \"$class\", \"tooltip\": \"$tooltip\"}"
