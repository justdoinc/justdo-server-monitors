# THIS FILE SHOULD BE CALLED BY ./launch-monitor.bash !

docker_container="$1"

log_file="${LOGS_DIR}/cpu-failure-restarter.log"

if [[ -z "$docker_container" ]]; then
    echo "cpu-failure-restart.bash <docker-container-id>"

    exit 1
fi

sample_interval=30 # seconds
high_cpu_threshold=80 # percent
consecutive_high_cpu_samples_before_restart=3

consecutive_cpu_samples_count=0

send_sms_on_restart=( "${SERVER_MONITORS_MANAGERS_PHONE_NUMBERS[@]}" ) # Let all the managers know of the restart

sendRestartSMS () {
    if [[ "${#send_sms_on_restart[@]}" ]]; then
        n=${#send_sms_on_restart[*]}
        for (( i=0; i < n; i += 1 )); do
            item="${send_sms_on_restart[i]}"

            echo "INFO: Server $SERVER_NAME/$docker_container restarted due to high CPU" | ./bash-helpers/tools/twilio/twilio-sms.bash "$item" >> "$log_file"
        done
        unset i n item
    fi
}

# # Uncomment to test SMS submission
# sendRestartSMS
# exit

while : ; do
    # DOCKER > 1.11.2
    #cpu_usage_int=$(docker stats --no-stream "$docker_container" | tail -n1  | awk '{print $3}' | cut -f1 -d".")
    # DOCKER <= 1.11.2
    cpu_usage_int=$(docker stats --no-stream "$docker_container" | tail -n1  | awk '{print $2}' | cut -f1 -d".")
    # cut -f1 -d"." removes the float part and % sign.

    if (( "$cpu_usage_int" > "$high_cpu_threshold" )); then
        consecutive_cpu_samples_count=$(($consecutive_cpu_samples_count + 1))

        echo "$(date) :: ($consecutive_cpu_samples_count) high cpu count found on $docker_container (${cpu_usage_int}% > ${high_cpu_threshold}%)" >> "$log_file"
    else
        consecutive_cpu_samples_count=0
    fi

    if [[ "$consecutive_cpu_samples_count" == "$consecutive_high_cpu_samples_before_restart" ]]; then
        echo "$(date) :: RESTART $docker_container" >> "$log_file"

        docker restart "$docker_container" >> "$log_file"

        sendRestartSMS

        consecutive_cpu_samples_count=0
    fi

    sleep "$sample_interval"
done

