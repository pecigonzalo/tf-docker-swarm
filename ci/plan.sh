#!/usr/bin/env bash

set -e          # exit on command errors
set -o nounset  # abort on unbound variable
set -o pipefail # capture fail exit codes in piped commands
set -x          # execution tracing debug messages

pushd ci
trap popd EXIT

terraform get --update=true
terraform plan
