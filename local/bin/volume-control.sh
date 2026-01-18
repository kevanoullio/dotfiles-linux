#!/bin/bash

# 1. Find the Index of the active app stream (Sink Input)
TARGET=$(pactl list sink-inputs | grep "Sink Input #" | awk '{print $3}' | tr -d '#' | head -n 1)

# 2. If an app is playing, control its volume (Playback level)
if [ ! -z "$TARGET" ]; then
    # Get current volume as an integer
    CUR_VOL=$(pactl list sink-inputs | grep -A 15 "Sink Input #$TARGET" | grep "Volume:" | head -n 1 | awk '{print $5}' | tr -d '%')

    if [ "$1" == "up" ]; then
        if [ "$CUR_VOL" -lt 100 ]; then
            pactl set-sink-input-volume "$TARGET" +5%
        else
            pactl set-sink-input-volume "$TARGET" 100%
        fi
    elif [ "$1" == "down" ]; then
        pactl set-sink-input-volume "$TARGET" -5%
    else
        pactl set-sink-input-mute "$TARGET" toggle
    fi

# 3. Fallback: If nothing is playing, control the Default Output (Hardware level)
else
    # Get current hardware volume
    SINK_NAME=$(pactl get-default-sink)
    CUR_VOL=$(pactl list sinks | grep -A 15 "$SINK_NAME" | grep "Volume:" | head -n 1 | awk '{print $5}' | tr -d '%')

    if [ "$1" == "up" ]; then
        if [ "$CUR_VOL" -lt 100 ]; then
            pactl set-sink-volume "$SINK_NAME" +5%
        else
            pactl set-sink-volume "$SINK_NAME" 100%
        fi
    elif [ "$1" == "down" ]; then
        pactl set-sink-volume "$SINK_NAME" -5%
    else
        pactl set-sink-mute "$SINK_NAME" toggle
    fi
fi
