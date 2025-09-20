#!/bin/bash

# Weather script for Waybar using wttr.in
# Shows current weather with temperature and conditions

# Cache file to avoid too many API calls
CACHE_FILE="/tmp/waybar_weather_cache"
CACHE_DURATION=600  # 10 minutes

# Location (can be changed to your preferred location)
LOCATION="Phoenix,Arizona"  # Based on your timezone

# Check if cache is valid
if [[ -f "$CACHE_FILE" ]]; then
    cache_age=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE")))
    if [[ $cache_age -lt $CACHE_DURATION ]]; then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

# Function to get weather icon based on condition (using Font Awesome icons)
get_weather_icon() {
    case $1 in
        *"Sunny"*|*"Clear"*) echo "󰖙 " ;;  # Sun
        *"Partly cloudy"*|*"Partly Cloudy"*) echo "󰖕 " ;;  # Cloud
        *"Cloudy"*|*"Overcast"*) echo "󰖐 " ;;  # Cloud
        *"Rain"*|*"Drizzle"*|*"Light rain"*) echo "󰖗 " ;;  # Tint/rain
        *"Heavy rain"*|*"Shower"*) echo "󰖖 " ;;  # Tint/rain
        *"Snow"*|*"Blizzard"*) echo "󰖘 " ;;  # Snowflake
        *"Thunderstorm"*|*"Thunder"*) echo "󰖓 " ;;  # Bolt
        *"Fog"*|*"Mist"*) echo "󰖑 " ;;  # Cloud
        *"Wind"*) echo "󰖝 " ;;  # Wind
        *) echo "󰖐 " ;;  # Default cloud
    esac
}

# Get weather data
weather_data=$(curl -s "wttr.in/$LOCATION?format=%C+%t+%h+%w" 2>/dev/null)

if [[ $? -ne 0 ]] || [[ -z "$weather_data" ]]; then
    output='{"text": " Weather unavailable", "class": "weather-error", "tooltip": "Unable to fetch weather data"}'
    echo "$output"
    exit 0
fi

# Parse weather data - extract condition from the raw format
# The format is: "condition temperature humidity wind"
# We need to extract everything before the temperature
temp=$(echo "$weather_data" | grep -o '+[0-9]*°[CF]' | head -1)
if [[ -n "$temp" ]]; then
    condition=$(echo "$weather_data" | sed "s/ $temp.*//")
else
    # Fallback parsing
    IFS=' ' read -r condition temp humidity wind <<< "$weather_data"
fi

# Parse remaining fields
if [[ -n "$temp" ]]; then
    # Extract humidity and wind from the remaining data
    remaining=$(echo "$weather_data" | sed "s/.*$temp //")
    IFS=' ' read -r humidity wind <<< "$remaining"
else
    # Fallback: parse remaining fields normally
    IFS=' ' read -r _ temp humidity wind <<< "$weather_data"
fi

# Clean condition string (remove trailing % or other characters)
condition=$(echo "$condition" | sed 's/[%]$//' | xargs)

# Get detailed weather info for tooltip
detailed_weather=$(curl -s "wttr.in/$LOCATION?format=%l:+%C+%t+(feels+like+%f)\nHumidity:+%h\nWind:+%w\nPressure:+%P" 2>/dev/null)

# Get weather icon
icon=$(get_weather_icon "$condition")

# Format temperature (remove + sign if present)
temp_clean=$(echo "$temp" | sed 's/+//')

# Create display text
text="$icon $temp_clean"

# Create tooltip
if [[ -n "$detailed_weather" ]]; then
    # Clean up the detailed weather by removing control characters and converting newlines properly
    tooltip=$(echo "$detailed_weather" | tr -d '\r' | sed 's/$/|/g' | tr -d '\n' | sed 's/|/\\n/g' | sed 's/\\n$//')
else
    tooltip="$condition $temp_clean\\nHumidity: $humidity\\nWind: $wind"
fi

# Determine CSS class based on temperature
temp_num=$(echo "$temp_clean" | sed 's/[°CF]//g' | sed 's/[^0-9-]//g')
if [[ $temp_num -gt 80 ]]; then
    class="weather-hot"
elif [[ $temp_num -lt 32 ]]; then
    class="weather-cold"
else
    class="weather-mild"
fi

# Create output using jq for proper JSON escaping
if command -v jq >/dev/null 2>&1; then
    output=$(jq -nc \
              --arg text "$text" \
              --arg class "$class" \
              --arg tooltip "$tooltip" \
              '{text: $text, class: $class, tooltip: $tooltip}')
else
    # Fallback if jq isn't available
    # Escape quotes and other special characters
    tooltip_escaped=$(echo "$tooltip" | sed 's/"/\\"/g')
    output="{\"text\": \"$text\", \"class\": \"$class\", \"tooltip\": \"$tooltip_escaped\"}"
fi

# Cache the result atomically
echo "$output" > "${CACHE_FILE}.tmp" && mv "${CACHE_FILE}.tmp" "$CACHE_FILE"
echo "$output"
