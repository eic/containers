#!/bin/sh

for i in /etc/profile.d/*.sh; do
  if [ -r "$i" ]; then
    . "$i"
  fi
done

## default PS1 preamble in case we can't find better info
PS1_PREAMBLE='eic-shell> '
## try to guess who we are
## note: we use sigils for the following cases:
## - no sigil for nightly builds (jug_xl> )
## - (*) for master builds     (jug_xl*> )
## - (+) for stable (versioned) (jug_xl+> )
## - (?) for unstable (MR)      (jug_xl?> )
if [ -f /etc/jug_info ]; then
  container=$(grep -e 'jug_' /etc/jug_info | tail -n 1 | awk '{print($2);}')
  container=${container%:}              ## jug_xl
  version=$(grep -e 'jug_' /etc/jug_info | tail -n 1 | awk '{print($3);}')
  if [ -n "${container}" ]; then
    case "${version}" in
      *unstable*) sigil="?" ;;
      *nightly*)  sigil="" ;;
      *testing*)  sigil="*" ;;
      *) sigil="+" ;;
    esac
    ps1_preamble="${container}${sigil}> "
    export PS1_SIGIL=${sigil}
    unset ${sigil}
  fi
  unset version
  unset container
fi
export PS1=${ps1_preamble}'\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33'
unset ps1_preamble

## unset CURL_CA_BUNDLE and SSL_CERT_FILE if not accessible
## inside container: this addresses certain HPC systems where
## CURL_CA_BUNDLE and SSL_CERT_FILE are customized to point
## to paths that do not exist inside this container
if [ ! -r ${CURL_CA_BUNDLE:-/} ]; then
  unset CURL_CA_BUNDLE
fi
if [ ! -r ${SSL_CERT_FILE:-/} ]; then
  unset SSL_CERT_FILE
fi

## redefine ls and less as functions, as this is something we
## can import into our plain bash --norc --noprofile session
## (aliases cannot be transferred to a child shell)
ls () {
  /bin/ls --color=auto "$@"
}
less () {
  /usr/bin/less -R "$@"
}
grep () {
  /bin/grep --color=auto "$@"
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
