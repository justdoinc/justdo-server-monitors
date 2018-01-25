#!/usr/bin/env bash

monitor_screen_name="server-monitors"
root_monitor_screen_name="root-server-monitors"

cd "$(dirname $0)" # cd to script dir

export NO_COLOR="${NO_COLOR:-"false"}"
for helper in bash-helpers/functions/*.bash; do
    . $helper
done

export MAIN_DIR="$(expandPath .)"

mkdir -p logs

if [[ ! -e ./conf.bash ]]; then
    announceErrorAndExit "Error: ./conf.bash isn't configured, copy default-conf.bash to conf.bash and configure"

    exit 1
fi

. ./conf.bash

announceStep "Launch user monitors"

screen -d -m -S "$monitor_screen_name" -c monitors.screen
echo "A detached screen started. To open use: $ screen -r $monitor_screen_name"

announceStep "Launch root monitors"

echo "Root password might be necessary for monitors that need root privileges"
sudo screen -d -m -S "$root_monitor_screen_name" -c root-monitors.screen
echo "A detached screen started for the root user monitors. To open use: $ sudo screen -r $root_monitor_screen_name"
