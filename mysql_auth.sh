#!/usr/bin/env bash
DB="custdb"
USER="spvuemysl"
PASS="passGood8%"

#Just one time
mysqladmin -u root password 'passGood8%'
#mysqladmin -u root password "$RPASS"
sudo su - root -c "/usr/bin/mysql -u root -ppassGood8% -h localhost -e \"create database $DB CHARACTER SET utf8 COLLATE utf8_general_ci; GRANT ALL PRIVILEGES ON custdb.* to '$USER'@'%' IDENTIFIED BY '$PASS'; FLUSH PRIVILEGES\" "
sudo su - root -c "/usr/bin/mysql -u root -ppassGood8% -h localhost -e \"GRANT ALL PRIVILEGES ON custdb.* to '$USER'@'localhost' IDENTIFIED BY '$PASS'; FLUSH PRIVILEGES\" "
