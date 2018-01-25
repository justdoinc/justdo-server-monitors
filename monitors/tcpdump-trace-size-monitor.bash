# THIS FILE SHOULD BE CALLED BY ./launch-monitor.bash !

send_sms_on_restart=( "${SERVER_MONITORS_DEVOPS_PHONE_NUMBERS[@]}" ) # Send SMS only to devops team

log_file="${LOGS_DIR}/tcpdump-trace-size-monitor.log"
tcp_dump_dir="${LOGS_DIR}/tcpdump"

sendRestartSMS () {
    if [[ "${#send_sms_on_restart[@]}" ]]; then
        n=${#send_sms_on_restart[*]}
        for (( i=0; i < n; i += 1 )); do
            item="${send_sms_on_restart[i]}"


            echo "$(date) INFO: TCP DUMP TOO BIG!" >> "$log_file"
            echo "INFO: TCP DUMP TOO BIG ON SERVER ${SERVER_NAME}!" | ./bash-helpers/tools/twilio/twilio-sms.bash "$item" >> "$log_file"
        done
        unset i n item
    fi
}

while : ; do
    if (( $(du -m "$tcp_dump_dir" | awk '{print $1}') > 2000 )); then
        sendRestartSMS

        exit
    fi

    sleep 15
done
