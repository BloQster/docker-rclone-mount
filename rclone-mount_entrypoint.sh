#!/bin/bash
set -e

function fuse_unmount {
  echo "Unmounting: fusermount $RCLONE_MOUNTPOINT at: $(date +%Y.%m.%d-%T)"
  fusermount -u -z "$RCLONE_MOUNTPOINT"
}

function term_handler {
  echo "Received SIGINT/TERM/STOP/KILL, propagating to rclone"
  kill -s TERM "$RCLONE_PID"
  fuse_unmount
  exit $?
}

trap term_handler SIGINT SIGTERM SIGSTOP SIGKILL

if [ ! -f "$RCLONE_CONFIG" ]; then
	echo "rclone config file does not exist."
	exit 1
fi


if [ -z "$RCLONE_REMOTE" ]; then
	echo "rclone remote not supplied"
	exit 2
fi

if [ -z "$RCLONE_MOUNTPOINT" ]; then
	echo "rclone remote not supplied"
	exit 3
fi

if [ -f "$RCLONE_CONFIG_PASS_SECRET_FILE" ]; then
	export RCLONE_CONFIG_PASS=$(cat "$RCLONE_CONFIG_PASS_SECRET_FILE")
fi

rclone mount "$RCLONE_REMOTE":/ "$RCLONE_MOUNTPOINT" ${RCLONE_MOUNTOPTS[@]} &
wait ${!}
echo "rclone crashed at: $(date +%Y.%m.%d-%T)"
fuse_unmount

exit $?
