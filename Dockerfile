FROM ubuntu:bionic
MAINTAINER Philipp Holler <philipp.holler93@googlemail.com>

# Set environment variables for build and entrypoint
ENV RCLONE_VERSION="v1.44" \
    RCLONE_CONFIG_DIR="/etc/rclone" \
    RCLONE_CONFIG="$RCLONE_CONFIG_DIR/rclone.conf" \
    RCLONE_CONFIG_PASS_SECRET_FILE="/run/secrets/rclone_config_password"

RUN apt-get update \
 && apt-get install -y wget fuse ca-certificates \
 && rm -r /var/lib/apt/lists/* \
 && wget https://github.com/ncw/rclone/releases/download/${RCLONE_VERSION}/rclone-${RCLONE_VERSION}-linux-amd64.deb -O /tmp/rclone.deb \
 && dpkg -i /tmp/rclone.deb

# Volume for persistent data and configuration files
VOLUME ${RCLONE_CONFIG_DIR}

# Add entrypoint script and set its permissions
ADD /rclone-mount_entrypoint.sh /
RUN chmod +x /rclone-mount_entrypoint.sh
ENTRYPOINT ["/rclone-mount_entrypoint.sh"]