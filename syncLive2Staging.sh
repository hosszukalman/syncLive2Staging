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

# Remove all tables from staging DB.
echo "Drop all staging tables...";
mysqldump -h$stagingHost -u$stagingUser -p$stagingPass --add-drop-table --no-data $stagingDB | grep ^DROP | mysql -h$stagingHost -u$stagingUser -p$stagingPass $stagingDB;
echo "All staging tables dropped!";

# Import live DB to staging DB.
echo "Import live database into staging...";
echo "Import sructure of cache and log tables...";
mysqldump -h$liveHost -u$liveUser -p$livePass --no-data $liveDB watchdog `mysql -ND -h$liveHost -u$liveUser -p$livePass $liveDB -e "SHOW TABLES LIKE 'cache%'" | awk '{printf $1" "}'` | mysql -h$stagingHost -u$stagingUser -p$stagingPass $stagingDB;

echo "Importing other tables data...";
mysqldump -h$liveHost -u$liveUser -p$livePass $liveDB  --single-transaction -e --ignore-table=$liveDB.watchdog `mysql -ND -h$liveHost -u$liveUser -p$livePass $liveDB -e "SHOW TABLES LIKE 'cache%'" | awk -v liveDB=${liveDB} '{printf "--ignore-table="liveDB"."$1" "}'` | mysql -h$stagingHost -u$stagingUser -p$stagingPass $stagingDB;
echo "Import finished, staging site is synced with the live site!";

exit 0;
