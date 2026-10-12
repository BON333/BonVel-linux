#!/bin/bash

#so para flex 
tmux new-session -d 'bash' \; split-window -h -l 1 'ping youtube.com | lolcat' \; attach

