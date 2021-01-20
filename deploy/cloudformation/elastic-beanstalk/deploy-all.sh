#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-c] -b bucket -n name

Deploys all services to Elastic Beanstalk. 

This script is idempotent, and can be run repeatedly.

Available options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info
-n, --name      Name of the environment
-b, --bucket    Name of the S3 bucket to use for artifact upload
-c, --noclean   Skip cleaning up the artifact directory
EOF
  exit
}

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT

  # script cleanup here
  if [[ $noclean -eq 0 ]]; then
    if [[ ! -z "$temp_dir" ]]; then
      if [[ -d "$temp_dir" ]]; then
        rm -rf $temp_dir
      fi
    fi
  fi
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
  noclean=0
  bucket=''
  temp_dir="$script_dir/packages"
  env_name='watchn-eb'

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    --no-color) NO_COLOR=1 ;;
    -c | --noclean) noclean=1 ;;
    -b | --bucket)
      bucket="${2-}"
      shift
      ;;
    -n | --name)
      env_name="${2-}"
      shift
      ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  args=("$@")

  # check required params and arguments
  [[ -z "${bucket-}" ]] && die "Missing required parameter: bucket"

  return 0
}

parse_params "$@"
setup_colors

function package()
{
  component=$1
  output="$temp_dir/$component.zip"

  component_dir="$script_dir/../../../src/$component"

  msg "Building component ${GREEN}$component${NOFORMAT}"

  if [ ! -d "$component_dir" ]; then
    echo "Error: Component $component does not exist"
    exit 1
  fi

  if [ -d "$script_dir/$component" ]; then
    (cd $script_dir/$component && zip -q -r $output .)
    
  fi

  $component_dir/package.sh $output
}

if [ -d "$temp_dir" ]; then
  rm -rf $temp_dir
fi

mkdir -p $temp_dir

package catalog
package cart
package checkout
package orders
package assets
package ui

temp_file=$(mktemp)

aws cloudformation package --template-file $script_dir/cloudformation/main.yml --output-template $temp_file --s3-bucket $bucket

msg "\nDeploying CloudFormation stack ${GREEN}$env_name${NOFORMAT}"

aws cloudformation deploy --template-file $temp_file --stack-name $env_name --capabilities CAPABILITY_IAM --parameter-overrides EnvironmentName=$env_name

endpoint=$(aws cloudformation describe-stacks --stack-name $env_name --query "Stacks[0].Outputs[?OutputKey=='Endpoint'].OutputValue" --output text)

msg "\nWatchn endpoint: ${endpoint}"