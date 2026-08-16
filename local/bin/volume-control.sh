#!/bin/bash

# Use wpctl (PipeWire standard) or fallback to pactl
if command -v wpctl &> /dev/null; then
    case "$1" in
        up)
            # Increases active output device volume, capped strictly at 100% (1.0)
            wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+
            ;;
        down)
            wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
            ;;
        mute)
            wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
            ;;
    esac
else
    # Pactl fallback targeting active default sink only
    SINK_NAME=$(pactl get-default-sink)
    CUR_VOL=$(pactl get-sink-volume "$SINK_NAME" | head -n 1 | awk '{print $5}' | tr -d '%')

    case "$1" in
        up)
            if [ "$CUR_VOL" -lt 100 ]; then
                pactl set-sink-volume "$SINK_NAME" +5%
            else
                pactl set-sink-volume "$SINK_NAME" 100%
            fi
            ;;
        down)
            pactl set-sink-volume "$SINK_NAME" -5%
            ;;
        mute)
            pactl set-sink-mute "$SINK_NAME" toggle
            ;;
    esac
fi
