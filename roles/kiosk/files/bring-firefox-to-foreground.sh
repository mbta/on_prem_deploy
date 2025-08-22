#!/bin/bash

# force Firefox into the foreground

if [ "`pgrep -c firefox`" -gt "0" ]; then
    wmctrl -a firefox
fi
