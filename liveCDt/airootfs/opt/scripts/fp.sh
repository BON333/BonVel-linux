#!/bin/bash

#so para flex 
tmux new-session -d 'bash' \; split-window -h -l 40% 'ping youtube.com | lolcat' \; attach

