#!/usr/bin/env bash
set -euo pipefail

# Run ON the MongoDB VM, after cloud-init finishes.
# Prompts for the Tasky password without echoing or storing it in shell history.
read -r -p 'Tasky MongoDB username [tasky]: ' DB_USER
DB_USER="${DB_USER:-tasky}"
read -r -s -p 'Tasky MongoDB password: ' DB_PASSWORD
printf '\n'
if [[ -z "$DB_PASSWORD" ]]; then echo 'Password cannot be empty' >&2; exit 1; fi

# mongo shell is supplied by mongodb-org 4.4.
# MongoDB localhost exception permits the FIRST user to be created before auth is configured.
# Create an admin account first (separate from the app account).
read -r -s -p 'MongoDB admin password (for first-time setup): ' ADMIN_PASSWORD
printf '\n'
if [[ -z "$ADMIN_PASSWORD" ]]; then echo 'Admin password cannot be empty' >&2; exit 1; fi

export DB_USER DB_PASSWORD ADMIN_PASSWORD
python3 - <<'PY' >/tmp/tasky-users.js
import json, os
print('db = db.getSiblingDB("admin");')
print('db.createUser({user:"mongoAdmin",pwd:%s,roles:[{role:"root",db:"admin"}]});' % json.dumps(os.environ['ADMIN_PASSWORD']))
print('db = db.getSiblingDB("tasky");')
print('db.createUser({user:%s,pwd:%s,roles:[{role:"readWrite",db:"tasky"}]});' % (json.dumps(os.environ['DB_USER']), json.dumps(os.environ['DB_PASSWORD'])))
PY
chmod 600 /tmp/tasky-users.js
# First-user localhost exception allows creation of the admin user only; second user needs auth.
head -n 2 /tmp/tasky-users.js | mongo --quiet --host 127.0.0.1
# Authenticate to create the app user.
tail -n 2 /tmp/tasky-users.js | mongo --quiet --host 127.0.0.1 -u mongoAdmin -p "$ADMIN_PASSWORD" --authenticationDatabase admin
shred -u /tmp/tasky-users.js 2>/dev/null || rm -f /tmp/tasky-users.js
unset DB_PASSWORD ADMIN_PASSWORD
printf 'Tasky user created. Use database tasky with authSource=tasky in MONGODB_URI.\n'
