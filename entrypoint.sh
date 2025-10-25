#!/bin/sh
set -e

CONFIG_FILE="/app/config.json"

# Environment variable defaults
SOCKS_BIND="${SOCKS_BIND:-127.0.0.1}"
SOCKS_PORT="${SOCKS_PORT:-1080}"

# Check if configuration file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Configuration file not found, starting auto-registration..."
    /bin/usque register --accept-tos -c "$CONFIG_FILE"

    if [ $? -eq 0 ]; then
        echo "Registration successful! Configuration file created: $CONFIG_FILE"
    else
        echo "Registration failed! Please check network connection and try again"
        exit 1
    fi
else
    echo "Configuration file exists: $CONFIG_FILE"
fi

# If user provided command arguments, execute user's command
if [ $# -gt 0 ]; then
    echo "Starting service: usque $@"
    exec /bin/usque "$@"
else
    # Start default SOCKS5 proxy mode
    echo "Starting default SOCKS5 proxy mode"
    echo "Listening on: ${SOCKS_BIND}:${SOCKS_PORT}"

    # Build SOCKS5 startup command
    SOCKS_CMD="/bin/usque socks -c $CONFIG_FILE -b $SOCKS_BIND -p $SOCKS_PORT"

    # Add authentication parameters if username and password are set
    if [ -n "$SOCKS_USER" ] && [ -n "$SOCKS_PASS" ]; then
        echo "SOCKS5 authentication: Enabled"
        SOCKS_CMD="$SOCKS_CMD -u $SOCKS_USER -w $SOCKS_PASS"
    else
        echo "SOCKS5 authentication: Disabled"
    fi

    exec $SOCKS_CMD
fi
