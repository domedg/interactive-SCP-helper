#!/bin/bash

# Default configuration
#DEFAULT_USERNAME="your_default_username"
#DEFAULT_IP="192.168.1.186"
#DEFAULT_DESTINATION="/path/to/default/destination"
LOG_FILE="scp_transfer.log"

# Function to log transfers
log_transfer() {
    local status=$1
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $status | Source: $SOURCE | Destination: $USERNAME@$IP:$DESTINATION" >> "$LOG_FILE"
}

# Function to validate IP addresses
validate_ip() {
    local ip=$1
    if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        for i in $(echo $ip | tr "." " "); do
            if ((i < 0 || i > 255)); then
                return 1
            fi
        done
        return 0
    else
        return 1
    fi
}

# Function to validate the source (file or directory)
validate_source() {
    if [[ ! -e "$SOURCE" ]]; then
        echo "Error: The source file or directory does not exist!" >&2
        exit 1
    fi
}

# Function to execute the SCP command
execute_scp() {
    if [[ $TYPE == "f" ]]; then
        scp "$SOURCE" "$USERNAME@$IP:$DESTINATION"
    elif [[ $TYPE == "d" ]]; then
        scp -r "$SOURCE" "$USERNAME@$IP:$DESTINATION"
    else
        echo "Error: Unknown type. Use 'f' for file or 'd' for directory." >&2
        exit 1
    fi

    if [[ $? -eq 0 ]]; then
        echo "Transfer completed successfully!"
        log_transfer "SUCCESS"
    else
        echo "Error during the transfer!" >&2
        log_transfer "FAILURE"
        exit 1
    fi
}

# Welcome message
echo "Welcome to the interactive SCP helper script!"
echo

# User input
read -p "Are you transferring a file or a directory? [f/d]: " TYPE
read -p "Source path: " SOURCE
read -p "Username [Press Enter for default]: " USERNAME
USERNAME="${USERNAME:-$DEFAULT_USERNAME}"
read -p "IP address [Press Enter for default]: " IP
IP="${IP:-$DEFAULT_IP}"
read -p "Destination path [Press Enter for default]: " DESTINATION
DESTINATION="${DESTINATION:-$DEFAULT_DESTINATION}"

# Input validation
validate_source
if ! validate_ip "$IP"; then
    echo "Error: The entered IP address is invalid!" >&2
    exit 1
fi

# Transfer confirmation
echo
echo "Transfer details:"
echo " - Type: $( [[ $TYPE == "f" ]] && echo 'File' || echo 'Directory' )"
echo " - Source: $SOURCE"
echo " - Destination: $USERNAME@$IP:$DESTINATION"
read -p "Proceed with the transfer? [y/n]: " CONFIRM
if [[ $CONFIRM != "y" ]]; then
    echo "Transfer canceled."
    exit 0
fi

# Execute the SCP command
execute_scp 
