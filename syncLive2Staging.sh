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

# Create backup from staging DB.
echo "Export staging database...";
mysqldump -h$stagingHost -u$stagingUser -p$stagingPass $stagingDB --add-drop-table -e | gzip > $backupPath`date "+%y%m%d_%H%M"`_$stagingDB.sql.gz;
echo "Staging database is exported to $backupPath`date "+%y%m%d_%H%M"`_$stagingDB.sql.gz";
