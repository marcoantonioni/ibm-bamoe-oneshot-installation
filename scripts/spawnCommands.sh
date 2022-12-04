#!/bin/bash

MAX_SHELL=30
for (( c=1; c<=$MAX_SHELL; c++ )) do gnome-terminal --tab -- ./startProcessTimer.sh; done