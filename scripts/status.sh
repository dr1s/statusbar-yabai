#!/usr/bin/bash

battery_charging=$(pmset -g batt | grep "'.*'" | sed "s/'//g" | cut -c 18-19)
battery_percentage=$(pmset -g batt | grep -E '([0-9]+\%).*' -o --colour=auto | cut -f1 -d'%')
time=$(date "+%H:%M")
date=$(date "+%a, %b %d %Y")

echo "${time}@${date}@${battery_percentage}@${battery_charging}@$(sh ./scripts/wifi_status_script)@$(sh ./scripts/getVolumeStat.sh)"
