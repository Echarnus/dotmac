#!/bin/bash
# Tmux battery status

# Color codes
GREEN="#[fg=colour76,bg=colour237,bold]"
BLUE="#[fg=colour81,bg=colour237,bold]"
ORANGE="#[fg=colour208,bg=colour237,bold]"
PURPLE="#[fg=colour141,bg=colour237,bold]"
YELLOW="#[fg=colour228,bg=colour237,bold]"
RESET="#[fg=colour137,bg=colour234,nobold]"
SEP="#[fg=colour237,bg=colour234]"
SPACE=" "

battery_percent=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
if [[ -n "$battery_percent" ]]; then
    # Determine battery icon and color based on percentage
    if [[ $battery_percent -ge 80 ]]; then
        battery_icon="🔋"
        battery_color="${GREEN}"
    elif [[ $battery_percent -ge 60 ]]; then
        battery_icon="🔋"
        battery_color="${GREEN}"
    elif [[ $battery_percent -ge 40 ]]; then
        battery_icon="🔋"
        battery_color="${YELLOW}"
    elif [[ $battery_percent -ge 20 ]]; then
        battery_icon="🔋"
        battery_color="${ORANGE}"
    else
        battery_icon="🪫"
        battery_color="${PURPLE}"
    fi
    
    # Check if charging
    if pmset -g batt | grep -q "AC Power"; then
        battery_icon="⚡"
        battery_color="${BLUE}"
    fi
    
    echo "${SEP}${battery_color} ${battery_icon} ${battery_percent}% ${RESET}${SPACE}"
fi
