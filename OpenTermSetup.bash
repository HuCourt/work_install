#!/bin/bash
session=work

SESSIONEXISTS=$(tmux list-sessions | grep $session)

if [ "$SESSIONEXISTS" = "" ]
then
cd "Documents/argos"
tmux new-session -s $session -d
tmux split-window -h
tmux send-keys -t $session:1 'birdtray&' C-m
tmux new-window
tmux send-keys -t $session:2 'vim' C-m
tmux select-window -t 1
fi

gnome-terminal -- tmux new-session -t work;tmux select-window -t 2

tmux attach-session -t $session:1




