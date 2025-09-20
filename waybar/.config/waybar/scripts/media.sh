#!/bin/bash

# Enhanced media control script for Waybar
# Supports multiple players and shows detailed info

# Get the first active player
player=$(playerctl -l 2>/dev/null | head -1)

if [[ -z "$player" ]]; then
    echo '{"text": " No player", "class": "no-media", "tooltip": "No media player active"}'
    exit 0
fi

# Get media info
status=$(playerctl -p "$player" status 2>/dev/null)
if [[ $? -ne 0 ]]; then
    echo '{"text": " No media", "class": "no-media"}'
    exit 0
fi

title=$(playerctl -p "$player" metadata title 2>/dev/null)
artist=$(playerctl -p "$player" metadata artist 2>/dev/null)
album=$(playerctl -p "$player" metadata album 2>/dev/null)
position=$(playerctl -p "$player" position --format "{{ duration(position) }}" 2>/dev/null)
duration=$(playerctl -p "$player" metadata --format "{{ duration(mpris:length) }}" 2>/dev/null)

# Set icon based on status
case $status in
    "Playing") icon="󰏤 " ;;
    "Paused") icon="󰐊 " ;;
    *) icon="" ;;
esac

# Function to escape JSON strings
escape_json() {
    local input="$1"
    # Replace backslashes first, then quotes, newlines, and other special chars
    input="${input//\\/\\\\}"
    input="${input//\"/\\\"}"
    input="${input//$'\n'/\\n}"
    input="${input//$'\r'/\\r}"
    input="${input//$'\t'/\\t}"
    echo "$input"
}

# Format display text
if [[ -n "$artist" && -n "$title" ]]; then
    text="$icon $artist - $title"
    tooltip="$title\nby $artist"
    [[ -n "$album" ]] && tooltip="$tooltip\nfrom $album"
    [[ -n "$position" && -n "$duration" ]] && tooltip="$tooltip\n$position / $duration"
elif [[ -n "$title" ]]; then
    text="$icon $title"
    tooltip="$title"
else
    text="$icon Unknown"
    tooltip="Unknown media"
fi

# Limit text length
if [[ ${#text} -gt 50 ]]; then
    text="${text:0:47}..."
fi

# Set CSS class based on status
class="media-$status"

# Escape JSON strings
text_escaped=$(escape_json "$text")
tooltip_escaped=$(escape_json "$tooltip")

echo "{\"text\": \"$text_escaped\", \"class\": \"$class\", \"tooltip\": \"$tooltip_escaped\"}"
