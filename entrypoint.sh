#!/bin/bash

# Log the active timezone and current time for verification
echo "Active Timezone: ${TZ:-System Default}"
echo "Current Time: $(date)"
echo "Starting Speedtest loop every ${SPEEDTEST_INTERVAL} seconds..."

DATA_DIR="/usr/local/speedtest-data"

while true; do
    # This date command automatically uses the TZ environment variable
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    CURRENT_HOSTNAME=$(hostname)
    
    FILE_PATH="${DATA_DIR}/${CURRENT_HOSTNAME}_${TIMESTAMP}.json"
    
    echo "Running speedtest at $(date)..."
    
    speedtest --accept-license --accept-gdpr -f json ${SPEEDTEST_ARGS} > "${FILE_PATH}"
    
    echo "Results successfully saved to ${FILE_PATH}"
    echo "Waiting ${SPEEDTEST_INTERVAL} seconds..."
    
    sleep "${SPEEDTEST_INTERVAL}"
done