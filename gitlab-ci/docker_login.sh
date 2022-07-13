#!/bin/bash

## Resilient docker login with multiple progressive retries in case of TLS issues

function print_the_help {
  echo "USAGE:  -u user -p -password [...] [registry]"
  echo "ARGUMENTS:"
  echo "          -u,--user       Registry user"
  echo "          -p,--password   Registry password"
  echo "          --ci            Login to internal CI registry; -u, -p and positional are ignored"
  echo "          -t,--time       Time interval (in seconds) between attempts"
  echo "                          (doubled each time), default: 5"
  echo "          -n,--n-attempts Number of attempts, default: 5"
  echo "          -h,--help       Print this message"
  echo "  positional       Registry name (will use dockerhub if none given)"
  echo ""
  echo "  Login to registry."
  echo ""
  echo "EXAMPLE: ./docker_login.sh -u \$CI_REGISTRY_USER -p \$CI_REGISTRY_PASSWORD \$CI_REGISTRY" 
  exit
}

REGISTRY=
REG_USER=
REG_PASSWORD=
NTRIES=5
TIME=5
CI=

while [ $# -gt 0 ]; do
  key=$1
  case $key in
    -u|--user)
      REG_USER=$2
      shift
      shift
      ;;
    -p|--password)
      REG_PASSWORD=$2
      shift
      shift
      ;;
    --ci)
      CI=1
      shift
      ;;
    -t|--time)
      TIME=$2
      shift
      shift
      ;;
    -n|--n-attempts)
      NTRIES=$2
      shift
      shift
      ;;
    -h|--help)
      print_the_help
      exit 0
      ;;
    -*)
      echo "ERROR: unknown flag: $key"
      echo "use --help for more info"
      exit 1
      ;;
    *)
      REGISTRY+="$1"
      shift
      ;;
  esac
done

## only sanizize input if not in CI registry mode
if [ -z $CI ]; then
  if [ -z $REG_USER ]; then
    echo "ERROR: no username given, please use -u <USER>"
    print_the_help
    exit 1
  fi
  if [ -z $REG_PASSWORD ]; then
    echo "ERROR: no password given, please use -p <PASSWORD>"
    print_the_help
    exit 1
  fi
else
  REGISTRY=$CI_REGISTRY
  REG_USER=$CI_REGISTRY_USER
fi

while [ $NTRIES != 0 ]; do
  if [ -z $CI ]; then
    echo $REG_PASSWORD | docker login -u $REG_USER \
                                     --password-stdin $REGISTRY \
      && break \
      || echo "Login failed, retrying in $TIME seconds..."
  else
    echo $CI_REGISTRY_PASSWORD | docker login -u $REG_USER \
                                              --password-stdin $REGISTRY \
      && break \
      || echo "Login failed, retrying in $TIME seconds..."
  fi
  sleep ${TIME}s
  TIME=$((TIME * 2))
  NTRIES=$((NTRIES - 1))
done
if [ $NTRIES = 0 ]; then
  echo "Failed to login to registry $REGISTRY"
  exit 1
fi
echo "Docker login to $REGISTRY successful"
