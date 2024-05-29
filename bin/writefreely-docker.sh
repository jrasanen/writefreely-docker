#! /bin/sh
## Writefreely wrapper for Docker
## Copyright (C) 2019 Gergely Nagy
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

set -e

cd /data

WRITEFREELY=/writefreely/writefreely
attempts=0
max_attempts=5

log() {
  echo "$(date '+%Y/%m/%d %H:%M:%S') $1"
}

validate_url() {
  URL="$1"
  if echo "$URL" | grep -Eq "^https?://[a-zA-Z0-9._-]+"; then
    return 0  # Success
  else
    return 1  # Failure
  fi
}

retry_command() {
  local cmd=$1
  attempts=0
  until $cmd; do
    attempts=$((attempts+1))
    if [ $attempts -ge $max_attempts ]; then
      log "Failed to execute '$cmd' after $attempts attempts."
      return 1
    fi
    log "Retrying '$cmd' ($attempts/$max_attempts)..."
    sleep 5
  done
  return 0
}

initialize_database() {
  log "Initializing database..."
  if ! retry_command "${WRITEFREELY} --init-db"; then
    log "Initialization of database failed. Removing config.ini."
    rm ./config.ini
    exit 1
  fi
}

generate_keys() {
  log "Generating keys..."
  ${WRITEFREELY} --gen-keys
}

create_admin_user() {
  if [ -n "$WRITEFREELY_ADMIN_USER" ]; then
    ${WRITEFREELY} user create --admin ${WRITEFREELY_ADMIN_USER}:${WRITEFREELY_ADMIN_PASSWORD}
    log "Created admin user ${WRITEFREELY_ADMIN_USER}"
  else
    log "Admin user not defined"
    exit 1
  fi
}

create_writer_user() {
  if [ -n "$WRITEFREELY_WRITER_USER" ]; then
    ${WRITEFREELY} user create ${WRITEFREELY_WRITER_USER}:${WRITEFREELY_WRITER_PASSWORD}
    log "Created writer user ${WRITEFREELY_WRITER_USER}"
  fi
}

validate_url "$WRITEFREELY_HOST" || {
  log "Error: $WRITEFREELY_HOST is not a valid URL. It must start with http:// or https:// and be followed by a valid hostname."
  exit 1
}

if [ -e ./config.ini ] && [ -e ./keys/email.aes256 ]; then
  log "Migration required. Running migration..."
  ${WRITEFREELY} -migrate
  exec ${WRITEFREELY}
fi

if [ -e ./config.ini ]; then
  initialize_database
  generate_keys
  create_admin_user
  create_writer_user
  exec ${WRITEFREELY}
fi

WRITEFREELY_BIND_PORT="${WRITEFREELY_BIND_PORT:-8080}"
WRITEFREELY_BIND_HOST="${WRITEFREELY_BIND_HOST:-0.0.0.0}"
WRITEFREELY_SITE_NAME="${WRITEFREELY_SITE_NAME:-A Writefreely blog}"
WRITEFREELY_SITE_DESCRIPTION="${WRITEFREELY_SITE_DESCRIPTION:-My Writefreely blog}"

cat >./config.ini <<EOF
[server]
hidden_host           =
port                  = ${WRITEFREELY_BIND_PORT}
bind                  = ${WRITEFREELY_BIND_HOST}
tls_cert_path         =
tls_key_path          =
autocert              =
templates_parent_dir  = /writefreely
static_parent_dir     = /writefreely
pages_parent_dir      = /writefreely
keys_parent_dir       =
hash_seed             =
gopher_port           = 0

[database]
type                  = ${WRITEFREELY_DATABASE_DATABASE}
filename              = ${WRITEFREELY_SQLITE_FILENAME:-/data/writefreely.db}
username              = ${WRITEFREELY_DATABASE_USERNAME}
password              = ${WRITEFREELY_DATABASE_PASSWORD}
database              = ${WRITEFREELY_DATABASE_NAME}
host                  = ${WRITEFREELY_DATABASE_HOST}
port                  = ${WRITEFREELY_DATABASE_PORT}
tls                   = false

[app]
site_name             = ${WRITEFREELY_SITE_NAME}
site_description      = ${WRITEFREELY_SITE_DESCRIPTION}
host                  = ${WRITEFREELY_HOST:-http://${WRITEFREELY_BIND_HOST}:${WRITEFREELY_BIND_PORT}}
theme                 = write
editor                =
disable_js            = false
webfonts              = true
landing               =
simple_nav            = false
wf_modesty            = false
chorus                = false
forest                = false
disable_drafts        = false
single_user           = ${WRITEFREELY_SINGLE_USER:-false}
open_registration     = ${WRITEFREELY_OPEN_REGISTRATION:-false}
min_username_len      = ${WRITEFREELY_MIN_USERNAME_LEN:-3}
max_blogs             = ${WRITEFREELY_MAX_BLOG:-4}
federation            = ${WRITEFREELY_FEDERATION:-true}
public_stats          = ${WRITEFREELY_PUBLIC_STATS:-false}
monetization          = false
notes_only            = false
private               = ${WRITEFREELY_PRIVATE:-false}
local_timeline        = ${WRITEFREELY_LOCAL_TIMELINE:-false}
user_invites          = ${WRITEFREELY_USER_INVITES}
update_checks         = false
disable_password_auth = false

[email]
domain          =
mailgun_private =

[oauth.slack]
client_id          =
client_secret      =
team_id            =
callback_proxy     =
callback_proxy_api =

[oauth.writeas]
client_id          =
client_secret      =
auth_location      =
token_location     =
inspect_location   =
callback_proxy     =
callback_proxy_api =

[oauth.gitlab]
client_id          =
client_secret      =
host               =
display_name       =
callback_proxy     =
callback_proxy_api =

[oauth.gitea]
client_id          =
client_secret      =
host               =
display_name       =
callback_proxy     =
callback_proxy_api =

[oauth.generic]
client_id          =
client_secret      =
host               =
display_name       =
callback_proxy     =
callback_proxy_api =
token_endpoint     =
inspect_endpoint   =
auth_endpoint      =
scope              =
allow_disconnect   = false
map_user_id        =
map_username       =
map_display_name   =
map_email          =
EOF

chmod 600 ./config.ini

initialize_database
generate_keys
create_admin_user
create_writer_user

exec ${WRITEFREELY}
