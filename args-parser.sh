SUPPORTED_ARGS=""
SHORT_ARGS=""
MERGEABLE_ARGS=""
KEEP_ARGS=true

## ARGUMENTS PARSING 4 #################################################################

[[ $# -eq 0 ]] && main && exit $?

unset arg argn argm argv argt argk

argv="$*" ; argt=""

while [[ -n "$1" ]] ; do
  if [[ "$1" =~ \  && -n "$argn" ]] ; then
    declare "$argn=$1"

    unset argn && shift && continue
  elif [[ $1 =~ ^-{1}[a-zA-Z0-9]{1,2}+.*$ ]] ; then
    argm=${1:1}

    if [[ \ $SHORT_ARGS\  =~ \ $argm:!?([a-zA-Z0-9_]*) ]] ; then
      arg="${BASH_REMATCH[1]}"
    else
      declare -F showArgWarn &>/dev/null && showArgWarn "-$argm"
      shift && continue
    fi

    if [[ -z "$argn" ]] ; then
      argn=$arg
    else
      # shellcheck disable=SC2015
      [[ -z "$argk" ]] && ( declare -F showArgValWarn &>/dev/null && showArgValWarn "--$argn" ) || declare "$argn=true"
      argn=$arg
    fi

    if [[ ! $SUPPORTED_ARGS\  =~ !?$argn\  ]] ; then
      declare -F showArgWarn &>/dev/null && showArgWarn "-$argm"
      shift && continue
    fi

    if [[ ${BASH_REMATCH[0]:0:1} == "!" ]] ; then
      declare "$argn=true" ; unset argn ; argk=true
    else
      unset argk
    fi

    shift && continue
  elif [[ "$1" =~ ^-{2}[a-zA-Z]{1}[a-zA-Z0-9_-]+.*$ ]] ; then
    arg=${1:2}

    if [[ $arg == *=* ]] ; then
      IFS="=" read -ra arg <<< "$arg"

      argm="${arg[0]}" ; argm=${argm//-/_}

      if [[ ! $SUPPORTED_ARGS\  =~ $argm\  ]] ; then
        declare -F showArgWarn &>/dev/null && showArgWarn "--${arg[0]//_/-}"
        shift && continue
      fi

      # shellcheck disable=SC2015
      [[ -n "${!argm}" && $MERGEABLE_ARGS\  =~ $argm\  ]] && declare "$argm=${!argm} ${arg[*]:1:99}" || declare "$argm=${arg[*]:1:99}"

      unset argm && shift && continue
    else
      arg=${arg//-/_}

      if [[ -z "$argn" ]] ; then
        argn=$arg
      else
        # shellcheck disable=SC2015
        [[ -z "$argk" ]] && ( declare -F showArgValWarn &>/dev/null && showArgValWarn "--$argn" ) || declare "$argn=true"
        argn=$arg
      fi

      if [[ ! $SUPPORTED_ARGS\  =~ !?$argn\  ]] ; then
        declare -F showArgWarn &>/dev/null && showArgWarn "--${argn//_/-}"
        shift && continue
      fi

      if [[ ${BASH_REMATCH[0]:0:1} == "!" ]] ; then
        declare "$argn=true" ; unset argn ; argk=true
      else
        unset argk
      fi

      shift && continue
    fi
  else
    if [[ -n "$argn" ]] ; then
      # shellcheck disable=SC2015
      [[ -n "${!argn}" && $MERGEABLE_ARGS\  =~ $argn\  ]] && declare "$argn=${!argn} $1" || declare "$argn=$1"

      unset argn && shift && continue
    fi
  fi

  argt="$argt $1" ; shift

done

[[ -n "$argn" ]] && declare "$argn=true"

unset arg argn argm argk

# shellcheck disable=SC2015,SC2086
[[ -n "$KEEP_ARGS" ]] && main $argv || main ${argt:1}

########################################################################################
