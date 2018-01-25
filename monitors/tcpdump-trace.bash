# THIS FILE SHOULD BE CALLED BY ./launch-monitor.bash !

# Requires root priv

tcp_dump_dir="${LOGS_DIR}/tcpdump" # If you change this change also tcpdump-trace-size-monitor.bash
mkdir -p "$tcp_dump_dir"

tcpdump -i "$NETWORK_DEVICE_ID" -G 1800 -w $tcp_dump_dir/trace-%H-%M.pcap