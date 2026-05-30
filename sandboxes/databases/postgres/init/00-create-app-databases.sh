#!/bin/bash
# Runs once on first postgres boot. Creates the per-app databases and
# users that other sandboxes (jira, confluence, anything else that
# shares this instance) expect.
#
# Add a block here when you wire a new app sandbox to shared postgres.
set -e

create_app_db() {
  local app="$1"
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER ${app} WITH ENCRYPTED PASSWORD '${app}';
    CREATE DATABASE ${app}db OWNER ${app} ENCODING 'UTF8' TEMPLATE template0;
    GRANT ALL PRIVILEGES ON DATABASE ${app}db TO ${app};
EOSQL
  echo "  ✓ created database ${app}db owned by ${app}"
}

create_app_db jira
create_app_db confluence
