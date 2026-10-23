#!/usr/bin/env bash
set -euo pipefail

# Required root-owned config file: /etc/tasky-backup.env
# MONGODB_BACKUP_URI=mongodb://backupuser:...@127.0.0.1:27017/admin?authSource=admin
# STORAGE_ACCOUNT=<storage account name>
# STORAGE_CONTAINER=<backup container name>
source /etc/tasky-backup.env
: "${MONGODB_BACKUP_URI:?Missing MONGODB_BACKUP_URI}"
: "${STORAGE_ACCOUNT:?Missing STORAGE_ACCOUNT}"
: "${STORAGE_CONTAINER:?Missing STORAGE_CONTAINER}"

stamp="$(date -u +%Y%m%dT%H%M%SZ)"
archive="/tmp/mongodb-${stamp}.archive.gz"
trap 'rm -f "$archive"' EXIT

mongodump --uri="$MONGODB_BACKUP_URI" --gzip --archive="$archive"

# Azure CLI must be installed; VM identity must have Storage Blob Data Contributor.
az login --identity --allow-no-subscriptions >/dev/null
az storage blob upload \
  --account-name "$STORAGE_ACCOUNT" \
  --container-name "$STORAGE_CONTAINER" \
  --name "mongodb/${stamp}.archive.gz" \
  --file "$archive" \
  --auth-mode login \
  --overwrite false \
  --only-show-errors
