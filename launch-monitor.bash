#!/usr/bin/env bash

cd "$(dirname $0)" # cd to script dir

export NO_COLOR="${NO_COLOR:-"false"}"
for helper in bash-helpers/functions/*.bash; do
    . $helper
done

export MAIN_DIR="$(expandPath .)"

export LOGS_DIR="${MAIN_DIR}/logs"
mkdir -p "$LOGS_DIR"

. ./conf.bash

monitor_script_file_name="$1"

shift

. "monitors/$monitor_script_file_name" "$*"
