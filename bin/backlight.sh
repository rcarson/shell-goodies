#!/bin/bash -u
# backlight.sh
# Increment and Decrement brightness for smc::kbd_backlight
#
# Robert Carson <robert.carson@gmail.com>

if [[ $# -lt 1 ]]; then
  echo "usage: $(basename $0) [-i|-d]"
  exit 1
fi

function by_half_inc {
  local cur=${1} max=${2}
  [[ ${cur} -eq "0" ]] && cur=1
  new=$((cur * 2))
  if [[ ${new} -ge ${max} ]]; then
    echo ${max}
  else
    echo ${new}
  fi
}

function by_half_dec {
  local cur=${1} min=${2:-0}
  [[ ${cur} -le 1 ]] && cur=1

  new=$((cur / 2))
  if [[ ${new} -le ${min} ]]; then
    echo ${min}
  else
    echo ${new}
  fi
}

INC=false 
DEC=false 

while getopts "idn:" OPT; do
  case $OPT in
    i) INC=true;;
    d) DEC=true;;
    n) BACKLIGHT=${OPTARG}
  esac
done

BACKLIGHT_DIR="/sys/class/backlight/intel_backlight"
if [[ -d "/sys/class/backlight/${BACKLIGHT}" ]]; then
    BACKLIGHT_DIR="/sys/class/backlight/${BACKLIGHT}"
elif [[ -d "/sys/class/leds/${BACKLIGHT}" ]]; then
    BACKLIGHT_DIR="/sys/class/leds/${BACKLIGHT}"
else
    echo "Unable to find backlight/led device." >&2
    exit 2
fi


# get max brightness
max_bright=$(cat ${BACKLIGHT_DIR}/max_brightness)

# get current brightness
cur_bright=$(cat ${BACKLIGHT_DIR}/brightness)

if ${INC}; then
  echo $(by_half_inc "$cur_bright" "${max_bright}") > ${BACKLIGHT_DIR}/brightness
elif ${DEC}; then
  echo $(by_half_dec "$cur_bright") > ${BACKLIGHT_DIR}/brightness
else
  echo "usage: $(basename $0) [-i|-d]"
  exit 1
fi  
