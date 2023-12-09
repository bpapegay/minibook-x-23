#!/bin/bash
DEVICE=/dev/input/event8
STACK_POINTER_X=()
STACK_POINTER_Y=()
slot=0
while IFS='$\n' read -r line; do
    catch_id="$(echo $line | grep -a ABS_MT_TRACKING_ID | sed -En "s/^.*value (.*)/\1/p")"
    catch_slot="$(echo $line | grep -a ABS_MT_SLOT | sed -En "s/^.*value (.*)/\1/p")"
    catch_pointer_x="$(echo $line | grep -a ABS_MT_POSITION_X | sed -En "s/^.*value (.*)/\1/p")"
    catch_pointer_y="$(echo $line | grep -a ABS_MT_POSITION_Y | sed -En "s/^.*value (.*)/\1/p")"
    [[ -n $catch_slot ]] && slot=$catch_slot
    if [[ -n $catch_id ]] && [[ "$catch_id" -lt 0 ]]
    then
        if [ "$slot" -gt 0 ]
        then
            xdotool mousemove ${STACK_POINTER_X[0]} ${STACK_POINTER_Y[0]} 
        else
            xdotool mouseup 1
        fi
    fi  
    if [[ -n $catch_pointer_x ]] || [[ -n $catch_pointer_y ]]
    then
        # need to be fixed as evtest and xdotool don't use the same system
        # coordinates. Whem screen is rotated, the conversion formula
        # need to be updated.
        [[ -n $catch_pointer_y ]] && STACK_POINTER_X[slot]=$(( $catch_pointer_y ))
        [[ -n $catch_pointer_x ]] && STACK_POINTER_Y[slot]=$(( 1200 - $catch_pointer_x ))
        if [[ "$slot" -gt 0 ]] && [[ -n ${STACK_POINTER_X[$slot]} ]] && [[ -n ${STACK_POINTER_Y[$slot]} ]]
        then
            xdotool mousemove ${STACK_POINTER_X[$slot]} ${STACK_POINTER_Y[$slot]} mousedown 1
        fi
    fi
done < <(stdbuf -oL evtest $DEVICE)
