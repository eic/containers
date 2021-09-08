#!/bin/bash

for i in /etc/profile.d/*.sh; do
  if [ -r $i ]; then
    . $i
  fi
done

export PS1='eic-shell> \[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33'

## redefine ls and less as functions, as this is something we
## can import into our plain bash --norc --noprofile session
## (aliases cannot be transferred to a child shell)
ls () {
  /bin/ls --color=auto $@
}
less () {
  /usr/bin/less -R $@
}
grep () {
  /bin/grep --color=auto $@
}
MYSHELL=$(ps -p $$ | awk '{print($4);}' | tail -n1)
## only export the functions for bash, as this does not work
## in all shells and we only care about bash here. Note that
## the singularity startup runs in plain sh which requires the
## if statement
if [ "$MYSHELL" = "bash" ]; then
  export -f ls
  export -f less
  export -f grep
fi
unset MYSHELL
