#!/bin/bash

SCREEN="DSI-1"
XINPUT=("pointer:Goodix Capacitive TouchScreen")
DEVICES=("XXXX0000:05 0911:5288 Touchpad" "AT Translated Set 2 keyboard")

#uses the values output by monitor-sensor to call the rotate function
function rotate_ms {
    case $1 in
        "normal")
            rotate 0
            ;;
        "right-up")
            rotate 1
            ;;
        "bottom-up")
            rotate 2
            ;;
        "left-up")
            rotate 3
            ;;
    esac
}

function disable_devices {
    for dev in ${!DEVICES[@]};
    do
        echo "disabling ${DEVICES[$dev]}"
        xinput disable "${DEVICES[$dev]}"
    done
}

function enable_devices {
    for dev in ${!DEVICES[@]};
    do
        xinput enable "${DEVICES[$dev]}"
    done
}

function rotate {
    O_NAMES=("normal" "right" "inverted" "left")
    COORDS=("1, 0, 0, 0, 1, 0, 0, 0, 1" "0, 1, 0, -1, 0, 1, 0, 0, 1" "-1, 0, 1, 0, -1, 1, 0, 0, 1" "0, -1, 1, 1, 0, 0, 0, 0, 1")
    W_NAMES=("none" "cw" "half" "ccw")

    O_NO=$1

    TARGET_ORIENTATION=${O_NAMES[$O_NO]}

    echo "Rotating to" $TARGET_ORIENTATION

    #Rotate the screen
    xrandr --output $SCREEN --rotate $TARGET_ORIENTATION

    #Rotate libinput driver input devices
    for i in "${XINPUT[@]}"
    do
        xinput set-prop "$i" "Coordinate Transformation Matrix" ${COORDS[$O_NO]}
    done
}

while IFS='$\n' read -r line; do
    rotation="$(echo $line | sed -En "s/^.*orientation changed: (.*)/\1/p")"
    [[ !  -z  $rotation  ]] && rotate_ms $rotation
done < <(stdbuf -oL monitor-sensor)
