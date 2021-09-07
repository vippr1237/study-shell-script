#!/bin/bash

# Create WP Credential
DB_NAME="wordpress"
DB_USER=$DB_NAME
DB_PASSWORD="wordpress"
sleep 1
MYSQL_ROOT_PASS="root"
sleep 1
WEB_SERVER="10.10.10.5"

# Install mysql
if [ $(service --status-all | grep -q "mysql" && echo $?) ]
then
        echo "mysql is available"
else
        echo "install mysql"
        sudo apt -y install mysql-server
fi
sudo systemctl enable mysql
sudo systemctl start mysql

#set root password
sudo /usr/bin/mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY '$MYSQL_ROOT_PASS';"
sudo /usr/bin/mysql -e "FLUSH PRIVILEGES;"

# login mysql without password as root user
if [ -f /root/.my.cnf ]
then
        echo "already config .my.cnf file"
else
        sudo touch /root/.my.cnf
        sudo chmod 640 /root/.my.cnf
        sudo echo "[client]">>/root/.my.cnf
        sudo echo "user=root">>/root/.my.cnf
        sudo echo "password=$MYSQL_ROOT_PASS">>/root/.my.cnf
fi

# Create database for wordpress server

/usr/bin/mysql -u root -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
/usr/bin/mysql -u root -e "DROP USER IF EXISTS '$DB_USER'@'$WEB_SERVER';"
/usr/bin/mysql -u root -e "CREATE USER '$DB_USER'@'$WEB_SERVER' IDENTIFIED WITH mysql_native_password BY '$DB_PASSWORD';"
/usr/bin/mysql -u root -e "FLUSH PRIVILEGES;"

# Change firewall rules and mysql binding ports
sudo ufw allow from $WEB_SERVER to any port 3306
sed -i "s/bind-address          = 127.0.0.1/bind_address                = 0.0.0.0/g" /etc/mysql/mysql.conf.d/mysqld.cnf
echo "SUCESS INSTALL MYSQL"
