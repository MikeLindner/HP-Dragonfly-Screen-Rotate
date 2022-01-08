#!/bin/sh
# Auto rotate screen based on device orientation

# https://github.com/MikeLindner/HP-Dragonfly-Screen-Rotate/blob/main/autorotate.sh

# Referencing:
# https://linuxappfinder.com/blog/auto_screen_rotation_in_ubuntu
# https://gist.github.com/mildmojo/48e9025070a2ba40795c
# https://gist.github.com/prolic/21673f0909c0cb5e2114

# Receives input from monitor-sensor (part of iio-sensor-proxy package)
# Screen orientation and launcher location is set based upon accelerometer position
# Launcher will be on the left in a landscape orientation and on the bottom in a portrait orientation
# This script should be added to startup applications for the user

TOUCHPAD='SynPS/2 Synaptics TouchPad'
TOUCHSCREEN='Wacom HID 4924 Finger'
TRANSFORM='Coordinate Transformation Matrix'

# Clear sensor.log so it doesn't get too long over time
> sensor.log

# Launch monitor-sensor and store the output in a variable that can be parsed by the rest of the script
monitor-sensor >> sensor.log 2>&1 &

# Parse output or monitor sensor to get the new orientation whenever the log file is updated
# Possibles are: normal, bottom-up, right-up, left-up
# Light data will be ignored
while inotifywait -e modify sensor.log; do
# Read the last line that was added to the file and get the orientation
ORIENTATION=$(tail -n 1 sensor.log | grep 'orientation' | grep -oE '[^ ]+$')

# Set the actions to be taken for each possible orientation
case "$ORIENTATION" in
normal)
xrandr -o normal && xinput set-prop "$TOUCHSCREEN" "$TRANSFORM" 1 0 0 0 1 0 0 0 1 ;;
bottom-up)
xrandr -o inverted && xinput set-prop "$TOUCHSCREEN" "$TRANSFORM" -1 0 1 0 -1 1 0 0 1 ;;
right-up)
xrandr -o right && xinput set-prop "$TOUCHSCREEN" "$TRANSFORM" 0 1 0 -1 0 1 0 0 1 ;;
left-up)
xrandr -o left && xinput set-prop "$TOUCHSCREEN" "$TRANSFORM" 0 -1 1 1 0 0 0 0 1  ;;
esac
done
