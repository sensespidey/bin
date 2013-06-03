#!/bin/sh
xrandr --output DVI-I-1 --mode 1920x1080 --rate 60
xrandr --output HDMI-1 --mode 1280x1024 --rate 60
xrandr --output DVI-I-1 --right-of HDMI-1
xrandr --output DVI-I-1 --primary
