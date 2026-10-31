# shellcheck shell=sh
## Load variables from data-only files without executing them.
##
## POSIX sh (works in bash, dash and busybox ash). Source this file, then:
##
##   load_vars [--defaults] [--export] FILE
##     FILE holds one KEY=value per line. Blank lines and lines starting
##     with '#' are ignored. No quoting, escaping, expansion or trailing
##     comments: the value is everything after the first '='.
##       KEY   must match ^[A-Z_][A-Z0-9_]*$
##       value must match ^[A-Za-z0-9._/:@+,-]*$
##     --defaults: a variable that is already set and non-empty keeps its
##                 value (same as VAR="${VAR:-default}").
##     --export:   export each variable.
##
##   load_list VAR FILE
##     FILE holds one item per line: <40-hex-sha> [<path>,<path>...] [# comment]
##     Sets VAR to the shas (newline-separated) and VAR_FILES to
##     '<sha>=<paths>' lines for the items that have a path list.
##
## Any line that does not match the grammar is an error (return 1); nothing
## is ever passed to eval except a validated variable name.

_lv_err() { printf 'load-vars: %s\n' "$*" >&2; }

_lv_valid_key() {
  case $1 in
    ''|[!A-Z_]*|*[!A-Z0-9_]*) return 1 ;;
  esac
}

_lv_valid_value() {
  case $1 in
    *[!A-Za-z0-9._/:@+,-]*) return 1 ;;
  esac
}

load_vars() {
  _lv_defaults=0 _lv_export=0
  while [ $# -gt 1 ]; do
    case $1 in
      --defaults) _lv_defaults=1 ;;
      --export) _lv_export=1 ;;
      *) _lv_err "unknown option: $1"; return 1 ;;
    esac
    shift
  done
  _lv_file=$1
  [ -r "${_lv_file}" ] || { _lv_err "cannot read ${_lv_file}"; return 1; }
  _lv_n=0
  while IFS= read -r _lv_line || [ -n "${_lv_line}" ]; do
    _lv_n=$((_lv_n + 1))
    case ${_lv_line} in
      ''|'#'*) continue ;;
      *=*) ;;
      *) _lv_err "${_lv_file}:${_lv_n}: expected KEY=value"; return 1 ;;
    esac
    _lv_key=${_lv_line%%=*}
    _lv_val=${_lv_line#*=}
    _lv_valid_key "${_lv_key}" \
      || { _lv_err "${_lv_file}:${_lv_n}: invalid key"; return 1; }
    _lv_valid_value "${_lv_val}" \
      || { _lv_err "${_lv_file}:${_lv_n}: invalid value for ${_lv_key}"; return 1; }
    if [ "${_lv_defaults}" = 1 ]; then
      eval "_lv_cur=\${${_lv_key}:-}"
      [ -n "${_lv_cur}" ] && _lv_val=${_lv_cur}
    fi
    # Safe: the key is validated; the value is referenced, not interpolated.
    eval "${_lv_key}=\${_lv_val}"
    [ "${_lv_export}" = 1 ] && export "${_lv_key?}"
  done < "${_lv_file}"
  return 0
}

load_list() {
  _lv_var=$1 _lv_file=$2
  _lv_valid_key "${_lv_var}" || { _lv_err "invalid variable name"; return 1; }
  [ -r "${_lv_file}" ] || { _lv_err "cannot read ${_lv_file}"; return 1; }
  _lv_items='' _lv_files='' _lv_n=0
  _lv_nl='
'
  while IFS= read -r _lv_line || [ -n "${_lv_line}" ]; do
    _lv_n=$((_lv_n + 1))
    _lv_line=${_lv_line%%#*}            # strip comment
    # shellcheck disable=SC2086         # intentional split on IFS whitespace
    set -f; set -- ${_lv_line}; set +f
    [ $# -eq 0 ] && continue
    [ $# -le 2 ] || { _lv_err "${_lv_file}:${_lv_n}: too many fields"; return 1; }
    case $1 in
      *[!0-9a-f]*) _lv_err "${_lv_file}:${_lv_n}: not a sha"; return 1 ;;
    esac
    [ ${#1} -eq 40 ] || { _lv_err "${_lv_file}:${_lv_n}: sha must be 40 hex digits"; return 1; }
    _lv_items=${_lv_items:+${_lv_items}${_lv_nl}}$1
    if [ $# -eq 2 ]; then
      case $2 in
        ''|-*|*[!A-Za-z0-9._/,+-]*) _lv_err "${_lv_file}:${_lv_n}: invalid path list"; return 1 ;;
      esac
      _lv_files=${_lv_files:+${_lv_files}${_lv_nl}}$1=$2
    fi
  done < "${_lv_file}"
  eval "${_lv_var}=\${_lv_items}"
  eval "${_lv_var}_FILES=\${_lv_files}"
  return 0
}
