#!/usr/bin/env bash
# Retrieve the public URL of the Cloud Run service for a given environment.

set -euo pipefail          # stop on error, on undefined variable, on failed pipe

ENVIRONMENT="${1:-}"       
REGION="europe-west1"
LOG_FILE="get-service-url.log"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $*" | tee -a "$LOG_FILE"
}

# 1. Check that the argument was provided
if [ -z "$ENVIRONMENT" ]; then
  log "ERROR: Missing argument"
  echo "Usage: $0 <environment>"
  exit 1
fi

# 2. Check that gcloud is installed
if ! command -v gcloud >/dev/null 2>&1; then
  log "ERROR: gcloud is not installed"
  exit 1
fi

SERVICE_NAME="php-app-${ENVIRONMENT}"

log "Looking up service ${SERVICE_NAME} in ${REGION}..."

# 3. Ask Cloud Run for the URL; if gcloud fails, handle it
if ! URL=$(gcloud run services describe "$SERVICE_NAME" \
      --region "$REGION" \
      --format='value(status.url)'); then
  log "ERROR: Could not descripe service"
  exit 1
fi

# 4. An empty result is also an error
if [ -z "$URL" ]; then
  log "ERROR: No URL"
  exit 1
fi

log "Service URL: ${URL}"
echo "$URL"
