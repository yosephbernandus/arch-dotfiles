#!/bin/bash

# Battery icons
ICON_BAT_CRITICAL="battery-caution"
ICON_BAT_LOW="battery-low"
ICON_BAT_CHARGING="battery-good-charging"
ICON_BAT_FULL="battery-full-charged"

# Create log file
LOG_FILE="/tmp/battery-monitor.log"
echo "Battery monitor started at $(date)" > "$LOG_FILE"

# Find the correct battery
for battery in /sys/class/power_supply/BAT*; do
    if [ -e "$battery/capacity" ]; then
        BATTERY_PATH="$battery"
        echo "Found battery at $BATTERY_PATH" >> "$LOG_FILE"
        break
    fi
done

if [ -z "$BATTERY_PATH" ]; then
    echo "No battery found!" >> "$LOG_FILE"
    exit 1
fi

# Warning thresholds
CRITICAL_THRESHOLD=10
LOW_THRESHOLD=20
FULL_THRESHOLD=95

# Variables to track state changes
LAST_CHARGING_STATE=2  # Starting with an invalid value
LAST_FULL_NOTIFIED=0

# Check if charging
is_charging() {
    STATUS=$(cat "$BATTERY_PATH/status")
    echo "Battery status: $STATUS" >> "$LOG_FILE"
    if [ "$STATUS" = "Charging" ]; then
        return 0
    else
        return 1
    fi
}

# Get battery percentage
get_battery_percentage() {
    CAPACITY=$(cat "$BATTERY_PATH/capacity")
    echo "Battery capacity: $CAPACITY%" >> "$LOG_FILE"
    echo "$CAPACITY"
}

# Function to send notification and log it
send_notification() {
    URGENCY="$1"
    ICON="$2"
    TITLE="$3"
    MESSAGE="$4"
    TIMEOUT="$5"
    
    echo "Sending notification: $TITLE - $MESSAGE" >> "$LOG_FILE"
    notify-send -u "$URGENCY" -i "$ICON" "$TITLE" "$MESSAGE" -t "$TIMEOUT"
}

# Main loop
while true; do
    BATTERY_PERCENTAGE=$(get_battery_percentage)
    
    # Check charging state
    if is_charging; then
        CURRENT_CHARGING_STATE=1
    else
        CURRENT_CHARGING_STATE=0
    fi
    
    echo "Current charging state: $CURRENT_CHARGING_STATE, Last state: $LAST_CHARGING_STATE" >> "$LOG_FILE"
    
    # Detect charging state changes
    if [ "$CURRENT_CHARGING_STATE" != "$LAST_CHARGING_STATE" ]; then
        if [ "$CURRENT_CHARGING_STATE" -eq 1 ]; then
            send_notification "low" "$ICON_BAT_CHARGING" "Battery Charging" "Battery at ${BATTERY_PERCENTAGE}%. Charger connected." "3000"
            LAST_FULL_NOTIFIED=0
        else
            send_notification "low" "$ICON_BAT_LOW" "Battery Discharging" "Battery at ${BATTERY_PERCENTAGE}%. Charger disconnected." "3000"
        fi
        LAST_CHARGING_STATE=$CURRENT_CHARGING_STATE
    fi
    
    # Check battery level conditions
    if is_charging; then
        if [ "$BATTERY_PERCENTAGE" -ge "$FULL_THRESHOLD" ] && [ "$LAST_FULL_NOTIFIED" -eq 0 ]; then
            send_notification "normal" "$ICON_BAT_FULL" "Battery Charged" "Battery at ${BATTERY_PERCENTAGE}%. You can disconnect the charger." "5000"
            LAST_FULL_NOTIFIED=1
        fi
    else
        if [ "$BATTERY_PERCENTAGE" -le "$CRITICAL_THRESHOLD" ]; then
            send_notification "critical" "$ICON_BAT_CRITICAL" "Battery Critically Low" "Battery at ${BATTERY_PERCENTAGE}%. Connect charger immediately!" "10000"
        elif [ "$BATTERY_PERCENTAGE" -le "$LOW_THRESHOLD" ]; then
            send_notification "normal" "$ICON_BAT_LOW" "Battery Low" "Battery at ${BATTERY_PERCENTAGE}%. Consider connecting your charger." "5000"
        fi
    fi
    
    echo "Sleeping for 30 seconds" >> "$LOG_FILE"
    sleep 1
done
