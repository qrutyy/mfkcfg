#!/usr/bin/bash

SESSION="w-main"

tmux kill-session -t $SESSION 2>/dev/null
tmux new-session -d -s $SESSION -n main

# Split first window horizontally
tmux split-window -h -t $SESSION:main

# 0.1 - left
tmux send-keys -t $SESSION:main.1 "cd engine && gs" C-m

# 0.2 right
tmux send-keys -t $SESSION:main.2 "cd engine" C-m

# 1. - second window
tmux new-window -d -t $SESSION -n nvim
tmux send-keys -t $SESSION:nvim "cd engine && nvim" C-m

tmux select-window -t $SESSION:main
tmux select-pane -t $SESSION:main.1

tmux attach-session -t $SESSION:main
