#!/bin/sh

# Read SOCKS configuration from environment variables
BIND="${SOCKS_BIND:-127.0.0.1}"
PORT="${SOCKS_PORT:-1080}"
USERNAME="${SOCKS_USER}"
PASSWORD="${SOCKS_PASS}"

# If binding to 0.0.0.0, use 127.0.0.1 for testing
if [ "$BIND" = "0.0.0.0" ]; then
    TEST_HOST="127.0.0.1"
else
    TEST_HOST="$BIND"
fi

# Build SOCKS proxy address
SOCKS_PROXY="${TEST_HOST}:${PORT}"

# Check connectivity to specified URL
check_url() {
    local url="$1"
    local http_code

    # Use different curl command based on authentication
    if [ -n "$USERNAME" ] && [ -n "$PASSWORD" ]; then
        http_code=$(curl --silent --fail \
            --connect-timeout 5 \
            --max-time 10 \
            --socks5 "$SOCKS_PROXY" \
            --proxy-user "$USERNAME:$PASSWORD" \
            "$url" \
            -o /dev/null \
            -w "%{http_code}" 2>/dev/null)
    else
        http_code=$(curl --silent --fail \
            --connect-timeout 5 \
            --max-time 10 \
            --socks5 "$SOCKS_PROXY" \
            "$url" \
            -o /dev/null \
            -w "%{http_code}" 2>/dev/null)
    fi

    echo "$http_code"
}

# Display configuration information
echo "[Health Check] Configuration:"
echo "  Bind Address: $BIND"
echo "  Port: $PORT"
echo "  Test Address: $SOCKS_PROXY"
if [ -n "$USERNAME" ] && [ -n "$PASSWORD" ]; then
    echo "  Authentication: Enabled (Username: $USERNAME)"
else
    echo "  Authentication: Disabled"
fi

# Test Google connectivity check endpoint
echo "[Health Check] Testing Google connectivity..."
status_google=$(check_url "http://connectivitycheck.gstatic.com/generate_204")
if [ "$status_google" = "204" ]; then
    echo "[Health Check] OK (Google connectivity check passed)"
    exit 0
fi

# Test Cloudflare connectivity check endpoint
echo "[Health Check] Testing Cloudflare connectivity..."
status_cloudflare=$(check_url "http://cp.cloudflare.com/")
if [ "$status_cloudflare" = "204" ]; then
    echo "[Health Check] OK (Cloudflare connectivity check passed)"
    exit 0
fi

# Test Cloudflare trace (fallback test)
echo "[Health Check] Testing Cloudflare trace..."
status_trace=$(check_url "https://cloudflare.com/cdn-cgi/trace")
if [ "$status_trace" = "200" ]; then
    echo "[Health Check] OK (Cloudflare trace check passed)"
    exit 0
fi

# All tests failed
echo "[Health Check] FAILED - SOCKS proxy cannot reach external network"
echo "  Google Status: $status_google"
echo "  Cloudflare Status: $status_cloudflare"
echo "  Trace Status: $status_trace"
exit 1
