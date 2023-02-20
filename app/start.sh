#!/bin/bash
# RShiny deployments do not pass system environment variables
# to the application. This script grabs the env vars set in docker
# and creates a config file which is read by the application on
# initialisation, then starts the application

# Delete any existing app config file
rm -f app_config.R

# Add environment vars from env into R config. This is done
# due to RShiny not passing system env vars to application
printf "ENV <- '%s'\n" "$NOMIS_ENV" >> app_config.R
printf "DB_NAME <- '%s'\n" "$NOMIS_DB_NAME" >> app_config.R
printf "HOSTNAME <- '%s'\n" "$NOMIS_DB_HOSTNAME" >> app_config.R
printf "DB_PORT <- %s\n" "$NOMIS_DB_PORT" >> app_config.R
printf "USERNAME <- '%s'\n" "$NOMIS_DB_USERNAME" >> app_config.R
printf "PASSWORD <- '%s'\n" "$NOMIS_DB_PASSWORD" >> app_config.R

# Run RShiny
/usr/bin/shiny-server
