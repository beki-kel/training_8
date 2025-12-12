#!/bin/sh
# ══════════════════════════════════════════════════════════
# Current - Docker Healthcheck Script
# ══════════════════════════════════════════════════════════
# Checks if the application is healthy and ready to serve
#
# Exit codes:
#   0 - Healthy
#   1 - Unhealthy
# ══════════════════════════════════════════════════════════

set -e


HOST="${HOST:-0.0.0.0}"
PORT="${PORT:-5000}"
TIMEOUT="${HEALTHCHECK_TIMEOUT:-5}"

if wget --spider --quiet --timeout="${TIMEOUT}" "http://${HOST}:${PORT}/api/health" 2>/dev/null; then
    exit 0
else
    if nc -z "${HOST}" "${PORT}" 2>/dev/null; then
        exit 0
    fi
    exit 1
fi
