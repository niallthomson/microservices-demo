#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-t <target>] [-d <duration>] [--dashboard] <store endpoint>

Runs a k6 load test against a Watchn store instance.

Available options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info
-d, --duration  Duration of the load test in minutes
-t, --target    Target number of virtual users
--dashboard     Makes a dashboard available while the generator is running (http://localhost:8888)
--no-fetch      Skips fetching JS, CSS and images on HTML pages
EOF
  exit
}

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT

  # script cleanup here
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

parse_params() {
  # default values of variables set from params
  target='20'
  duration='20'
  dashboard=false
  fetch='true'

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    --no-color) NO_COLOR=1 ;;
    -t | --target)
      target="${2-}"
      shift
      ;;
    -d | --duration)
      duration="${2-}"
      shift
      ;;
    --no-fetch) fetch='false' ;;
    --dashboard) dashboard=true ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  args=("$@")

  # check required params and arguments
  [[ ${#args[@]} -eq 0 ]] && die "You must specify the endpoint argument"

  return 0
}

parse_params "$@"
setup_colors

endpoint="${args[0]}"

msg "Running load test against endpoint:\n\n${endpoint}\n"

if [[ "$dashboard" = true ]]; then
  WATCHN_BASE_URL="${endpoint}" WATCHN_TARGET="${target}" WATCHN_DURATION="${duration}" WATCHN_FETCH="${fetch}" K6_OUT="influxdb=http://influxdb:8086/k6" docker-compose up --quiet-pull --build --exit-code-from k6

  docker-compose down
else
  docker run --rm -i -e "WATCHN_BASE_URL=${endpoint}" -e "WATCHN_TARGET=${target}" -e "WATCHN_DURATION=${duration}" -e "WATCHN_FETCH=${fetch}" loadimpact/k6:0.30.0 run - <js/script.js
fi
