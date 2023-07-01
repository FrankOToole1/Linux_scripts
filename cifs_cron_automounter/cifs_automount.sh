#!/bin/bash

# Define the CIFS share details
SERVER="//192.168.0.100"
SHARE="share"
MOUNT_POINT="/mnt/cifs"
USERNAME="user"
PASSWORD="pass"
RETRY_COUNT=5
TEST_FILE="test_file.txt"

# Function to check if the CIFS share is mounted
is_mounted() {
    mountpoint -q $MOUNT_POINT
}

# Function to create a test file on the CIFS share
create_test_file() {
    touch $MOUNT_POINT/$TEST_FILE
}

# Function to remove the test file from the CIFS share
remove_test_file() {
    rm -f $MOUNT_POINT/$TEST_FILE
}

# Function to log messages
log() {
    logger -t "CIFS Remount Script" "$1"
}

# Main script

# Check if the CIFS share is mounted
if is_mounted; then
    log "CIFS share is already mounted."
else
    log "CIFS share is not mounted. Remounting..."

    # Remount the CIFS share
    mount -t cifs $SERVER/$SHARE $MOUNT_POINT -o username=$USERNAME,password=$PASSWORD,retry=$RETRY_COUNT

    # Check if the remount was successful
    if is_mounted; then
        log "CIFS share remounted successfully."
        create_test_file

        # Check if the test file creation is successful
        if [ $? -eq 0 ] && [ -f "$MOUNT_POINT/$TEST_FILE" ]; then
            log "File-based test successful. CIFS share is accessible."
            remove_test_file
        else
            log "File-based test failed. CIFS share may be stale or inaccessible. Attempting unmount..."

            # Force unmount the share
            umount -l $MOUNT_POINT

            # Remount the CIFS share after unmounting
            mount -t cifs $SERVER/$SHARE $MOUNT_POINT -o username=$USERNAME,password=$PASSWORD,retry=$RETRY_COUNT

            # Check if the remount after unmount was successful
            if is_mounted; then
                log "CIFS share remounted successfully after unmount."
                create_test_file

                # Check if the test file creation is successful after remounting
                if [ $? -eq 0 ] && [ -f "$MOUNT_POINT/$TEST_FILE" ]; then
                    log "File-based test successful after remount. CIFS share is accessible."
                    remove_test_file
                else
                    log "Failed to create test file after remount. CIFS share may still be inaccessible."
                fi
            else
                log "Failed to remount CIFS share after unmount."
            fi
        fi
    else
        log "Failed to remount CIFS share."
    fi
fi

