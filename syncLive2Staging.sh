#! /bin/bash

# Staging site's data.
stagingUser=""
stagingPass=""
stagingDB=""
stagingHost="localhost";
backupPath="./"

# Live site's data.
liveUser="";
livePass="";
liveDB="";
liveHost="localhost";

# Clear cache tables before backup.
type drush &>/dev/null && (echo "Clear Drupal cache tables..."; drush cc all;)
