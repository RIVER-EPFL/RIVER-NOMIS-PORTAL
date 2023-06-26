#!/bin/bash
# RShiny deployments do not pass system environment variables
# to the application. This script grabs the env vars set in docker
# and creates a config file which is read by the application on
# initialisation, then starts the application

# Add environment vars from env into R config. This is done
# due to RShiny not passing system env vars to application
cat <<EOF > app_config.R
ENV <- '$NOMIS_ENV'
DB_NAME <- '$NOMIS_DB_NAME'
HOSTNAME <- '$NOMIS_DB_HOSTNAME'
DB_PORT <- $NOMIS_DB_PORT
USERNAME <- '$NOMIS_DB_USERNAME'
PASSWORD <- '$NOMIS_DB_PASSWORD'
EOF

# Write database dump config file
cat <<EOF > ~/.my.cnf
[client]
user=$NOMIS_DB_USERNAME
password=$NOMIS_DB_PASSWORD
host=$NOMIS_DB_HOSTNAME
port=$NOMIS_DB_PORT
EOF

# Run RShiny
/usr/bin/shiny-server
