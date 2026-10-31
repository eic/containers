#!/bin/sh
## Tests for scripts/load-vars.sh. Run under each shell:
##   for s in bash dash 'busybox sh'; do $s scripts/test-load-vars.sh; done
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
. "${HERE}/load-vars.sh"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
PWNED="$T/pwned"
pass=0 fail=0
ok()  { pass=$((pass + 1)); }
bad() { fail=$((fail + 1)); printf 'FAIL: %s\n' "$*"; }

## --- accepted input -------------------------------------------------------
cat > "$T/good.env" <<'X'
# comment
SPACK_ORGREPO=spack/spack

SPACK_VERSION=v1.2.2
SIZE_LIMIT_EIC_CI_GIB=3.1
CUDA_OS=ubuntu24.04
EMPTY=
X
printf 'NO_NEWLINE=1' >> "$T/good.env"
if load_vars "$T/good.env"; then ok; else bad "good.env rejected"; fi
[ "${SPACK_VERSION}" = v1.2.2 ] && ok || bad "SPACK_VERSION=${SPACK_VERSION}"
[ "${SPACK_ORGREPO}" = spack/spack ] && ok || bad "SPACK_ORGREPO"
[ "${NO_NEWLINE}" = 1 ] && ok || bad "last line without newline"
[ -z "${EMPTY}" ] && ok || bad "EMPTY"

## --defaults keeps environment, --export exports
printf 'CUDA_VERSION=12.8.2\nCUDA_OS=ubuntu24.04\n' > "$T/cuda.env"
CUDA_VERSION=13.0.0; unset CUDA_OS
load_vars --defaults --export "$T/cuda.env"
[ "${CUDA_VERSION}" = 13.0.0 ] && ok || bad "--defaults overrode env"
[ "${CUDA_OS}" = ubuntu24.04 ] && ok || bad "--defaults did not set unset var"
[ "$(sh -c 'printf %s "$CUDA_OS"')" = ubuntu24.04 ] && ok || bad "--export"

## --- rejected input: each must fail AND execute nothing -------------------
reject() { # name, line
  rm -f "${PWNED}"
  printf '%s\n' "$2" > "$T/bad.env"
  if load_vars "$T/bad.env" 2>/dev/null; then bad "$1 accepted"; else ok; fi
  [ -e "${PWNED}" ] && bad "$1 EXECUTED" || ok
}
reject 'command subst'  "X=\$(touch ${PWNED})"
reject 'backticks'      "X=\`touch ${PWNED}\`"
reject 'semicolon'      "X=a;touch ${PWNED}"
reject 'ampersand'      "X=a&&touch ${PWNED}"
reject 'pipe'           "X=a|touch ${PWNED}"
reject 'param expand'   'X=${HOME}'
reject 'double quotes'  'X="v1.2.2"'
reject 'single quotes'  "X='v1.2.2'"
reject 'space'          'X=a b'
reject 'trailing cmt'   'X=a # c'
reject 'glob'           'X=*'
reject 'tilde'          'X=~root'
reject 'lowercase key'  'x=1'
reject 'digit key'      '1X=1'
reject 'key injection'  "X;touch ${PWNED};Y=1"
reject 'key subst'      "\$(touch ${PWNED})=1"
reject 'no equals'      "touch ${PWNED}"
reject 'export prefix'  'export X=1'
reject 'CR line ending' "$(printf 'X=1\r')"
reject 'tab in value'   "$(printf 'X=a\tb')"

## A newline cannot be smuggled into a value: each line is parsed alone, so
## 'X=a' + newline + 'touch ...' fails on the second line.
rm -f "${PWNED}"
printf 'X=a\ntouch %s\n' "${PWNED}" > "$T/bad.env"
if load_vars "$T/bad.env" 2>/dev/null; then bad "newline accepted"; else ok; fi
[ -e "${PWNED}" ] && bad "newline EXECUTED" || ok

## --- lists ------------------------------------------------------------------
cat > "$T/picks" <<'X'
# <sha> [<path>,<path>]  # description
292b0dcaba3b2a5e3f9668d205d39fee2c715721  # fix: write created time field
678e506a95b319c573ba7e84703b06d7275ab80e lib/spack/a.py,lib/spack/b.py  # partial

0971885764f8d75ff838b4ab45f692a762888821
X
if load_list PICKS "$T/picks"; then ok; else bad "picks rejected"; fi
[ "$(printf '%s\n' "${PICKS}" | wc -l)" -eq 3 ] && ok || bad "PICKS count"
[ "${PICKS_FILES}" = "678e506a95b319c573ba7e84703b06d7275ab80e=lib/spack/a.py,lib/spack/b.py" ] \
  && ok || bad "PICKS_FILES=${PICKS_FILES}"

reject_list() {
  rm -f "${PWNED}"
  printf '%s\n' "$2" > "$T/bad.list"
  if load_list L "$T/bad.list" 2>/dev/null; then bad "list $1 accepted"; else ok; fi
  [ -e "${PWNED}" ] && bad "list $1 EXECUTED" || ok
}
reject_list 'short sha'   '292b0dc'
reject_list 'uppercase'   '292B0DCABA3B2A5E3F9668D205D39FEE2C715721'
reject_list 'subst'       "\$(touch ${PWNED})"
reject_list 'path subst'  "292b0dcaba3b2a5e3f9668d205d39fee2c715721 \$(touch ${PWNED})"
reject_list 'path option' '292b0dcaba3b2a5e3f9668d205d39fee2c715721 --output=/etc/x'
reject_list 'extra field' '292b0dcaba3b2a5e3f9668d205d39fee2c715721 a b'
reject_list 'glob'        '*'

printf '%s: %d passed, %d failed\n' "$(readlink /proc/$$/exe 2>/dev/null || echo sh)" "$pass" "$fail"
[ "$fail" -eq 0 ]
