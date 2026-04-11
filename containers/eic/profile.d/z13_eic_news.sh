#!/bin/bash

# The eic-news output is printed for opt-in users who have
# the file .eic-news in their home directory.
test -f "$HOME/.eic-news" && . /opt/local/bin/eic-news
