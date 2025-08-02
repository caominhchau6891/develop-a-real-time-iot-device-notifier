#!/bin/bash

# Project: Real-Time IoT Device Notifier

# Description:
# This script is designed to monitor and notify users of IoT device status in real-time.
# It uses MQTT protocol to receive updates from IoT devices and sends notifications
# to users via email or SMS.

# Configuration
MQTT_BROKER="localhost"
MQTT_PORT="1883"
DEVICE_TOPIC="iot/devices"
NOTIFY_EMAIL="admin@example.com"
NOTIFY_SMS="+1234567890"

# MQTT Subscription
mosquitto_sub -h $MQTT_BROKER -p $MQTT_PORT -t $DEVICE_TOPIC | while read -r line; do
  # Parse JSON payload
  device_id=$(echo "$line" | jq -r '.device_id')
  device_status=$(echo "$line" | jq -r '.status')

  # Send notification if device status changes
  if [ "$device_status" = "offline" ]; then
    echo "Device $device_id is offline!" | mail -s "Device Offline" $NOTIFY_EMAIL
    curl -X POST "https://example.com/sms-api?to=$NOTIFY_SMS&message=Device+$device_id+is+offline!"
  elif [ "$device_status" = "online" ]; then
    echo "Device $device_id is online!" | mail -s "Device Online" $NOTIFY_EMAIL
    curl -X POST "https://example.com/sms-api?to=$NOTIFY_SMS&message=Device+$device_id+is+online!"
  fi
done