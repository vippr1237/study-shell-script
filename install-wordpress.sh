#!/bin/bash

install_dir="/var/www/html"
DB_NAME="wordpress"
DB_USER=$DB_NAME
DB_PASSWORD="wordpress"
DB_HOST="10.10.10.4"

#check if apache service is available
if [ $(systemctl list-unit-files -t service | grep -c "httpd.service") != 0 ]
then
        echo "apache is available"
else
        echo "apache is not available"
        yum -y install httpd
fi

#start httpd
systemctl start httpd
systemctl enable httpd

#allow port 80
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --reload

#install php
yum -y install php php-mysql php-gd php-pear
systemctl restart httpd

#install wordpress
if test -f /tmp/wordpress-5.1.1.tar.gz
then
echo "WP is already downloaded."
else
echo "Downloading WordPress"
cd /tmp/ && wget https://wordpress.org/wordpress-5.1.1.tar.gz;
fi

/bin/tar -C $install_dir -zxf /tmp/wordpress-5.1.1.tar.gz --strip-components=1

# Create WP-config and set DB credentials
/bin/mv $install_dir/wp-config-sample.php $install_dir/wp-config.php

/bin/sed -i "s/database_name_here/$DB_NAME/g" $install_dir/wp-config.php
/bin/sed -i "s/username_here/$DB_USER/g" $install_dir/wp-config.php
/bin/sed -i "s/password_here/$DB_PASSWORD/g" $install_dir/wp-config.php
/bin/sed -i "s/localhost/$DB_HOST/g" $install_dir/wp-config.php

#Enable SELinux for apache remote connection
setsebool -P httpd_can_network_connect=1
