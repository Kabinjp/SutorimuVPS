#!/bin/sh
# Script for automatically install Nginx + PHP(php-fpm) + MySql + phpMyAdmin + filemanager

# Installation Requirement:
# CentOS 6.x 64 bit / CentOS 7.x 64 bit
# Guarantee Memory >= 256MB, Free Disk space >=2.5GB

clear
        echo "----------------------------------------------------------------------------";
        echo "-------------|              PREPARE REPO FOR YUM             |--------------";
        echo "-------------| _____________________________________________ |--------------";
        echo "----------------------------------------------------------------------------";
echo -e "\n";
arch=`uname -m`;
OS_MAJOR_VERSION=`sed -rn 's/.*([0-9])\.[0-9].*/\1/p' /etc/redhat-release`;
OS_MINOR_VERSION=`sed -rn 's/.*[0-9].([0-9]).*/\1/p' /etc/redhat-release`;
if [ "$arch" = "x86_64" ]; then
	if [ "$OS_MAJOR_VERSION" = 6 ]; then
	        yum -y install sudo;
		rpm --import http://ftp.riken.jp/Linux/fedora/epel/RPM-GPG-KEY-EPEL-6;
		rpm -ivh http://ftp.riken.jp/Linux/fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm;
		yum -y update epel-release;
		cp -p /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel.repo.org;
		sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/epel.repo;
		rpm --import http://rpms.famillecollet.com/RPM-GPG-KEY-remi
		rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm;
		yum -y update remi-release;
		rpm -ivh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm;
		yum -y update nginx-release-centos;
		cp -p /etc/yum.repos.d/nginx.repo /etc/yum.repos.d/nginx.repo.org;
		sudo sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/nginx.repo;
	else 
	        yum -y install sudo;
		rpm --import http://ftp.riken.jp/Linux/fedora/epel/RPM-GPG-KEY-EPEL-7;
		rpm -ivh http://ftp.riken.jp/Linux/fedora/epel/7/x86_64/e/epel-release-7-9.noarch.rpm;
		yum -y --enablerepo=remi -y update epel-release;
		cp -p /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel.repo.org;
		sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/epel.repo;
		rpm --import http://rpms.famillecollet.com/RPM-GPG-KEY-remi;
		rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm;
		yum -y update remi-release;
		rpm -ivh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm;
		yum -y update nginx-release-centos;
		cp -p /etc/yum.repos.d/nginx.repo /etc/yum.repos.d/nginx.repo.org;
		sudo sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/nginx.repo;
	fi
fi


#useradd nginx --home-dir=/www;

clear
        echo "----------------------------------------------------------------------------";
        echo "-------------|           INSTALL NGINX PHP + MYSQL           |--------------";
        echo "-------------| _____________________________________________ |--------------";
        echo "----------------------------------------------------------------------------";
echo -e "\n";
# You may want remove first if your server is not a clean OS
yum -y remove httpd nginx php php-* mysqld;
yum -y install wget;
yum -y install zip;
yum -y install unzip;
yum -y install yum-fastestmirror;

yum -y --enablerepo=remi-php71,epel install php-fpm php-gd php-gmp php-ldap php-bcmath php-apc php-mbstring php-pspell php-tidy php-mcrypt php-opcache php-pdo php-pear php-pecl-apc php-process php-pear-MDB2-Driver-mysqli php-pecl-memcached php-pecl-msgpack php-xml php-litespeed php-pecl-varnish php-intl php-zip php-soap php-imap;

yum -y --enablerepo=nginx install nginx;

clear
        echo "----------------------------------------------------------------------------";
        echo "-------------|        DOWNLOAD NGINX CONFIGURATION FILE      |--------------";
        echo "-------------| _____________________________________________ |--------------";
        echo "----------------------------------------------------------------------------";
echo -e "\n";
cp -p /etc/php.ini /etc/php.ini.org;
wget --no-check-certificate -O /etc/php.ini https://raw.githubusercontent.com/Kabinjp/SutorimuVPS/master/nginx-php-config.txt;
sed -i -e 's/;date.timezone =/date.timezone = "Asia\/Tokyo"/' /etc/php.ini;
cp -p /etc/php-fpm.d/www.conf /etc/php-fpm.d/www.conf.org;
sed -i -e 's/user = apache/user = nginx/' /etc/php-fpm.d/www.conf;
sed -i -e 's/group = apache/group = nginx/' /etc/php-fpm.d/www.conf;
sed -i -e 's/listen = 127.0.0.1:9000/listen = \/var\/run\/php-fpm\/php-fpm.sock/' /etc/php-fpm.d/www.conf;
sed -i -e 's/;listen.owner = nobody/listen.owner = nginx/' /etc/php-fpm.d/www.conf;
sed -i -e 's/;listen.group = nobody/listen.group = nginx/' /etc/php-fpm.d/www.conf;

cp -p /etc/nginx/nginx.conf /etc/nginx/nginx.conf.org;
sed -i -e "s/worker_processes  1;/worker_processes  `cat /proc/cpuinfo | grep processor | wc -l`;/" /etc/nginx/nginx.conf;
sudo sed -i -e 's/http_x_forwarded_for"'\'';/http_x_forwarded_for"'\'';\n    log_format  ltsv  '\''time:$time_local\\t'\''\n                      '\''host:$remote_addr\\t'\''\n                      '\''user:$remote_user\\t'\''\n                      '\''req:$request\\t'\''\n                      '\''status:$status\\t'\''\n                      '\''size:$body_bytes_sent\\t'\''\n                      '\''referer:$http_referer\\t'\''\n                      '\''ua:$http_user_agent\\t'\''\n                      '\''forwardedfor:$http_x_forwarded_for'\'';/' /etc/nginx/nginx.conf;
sudo sed -i -e 's/include \/etc\/nginx\/conf.d\/\*.conf;/include \/etc\/nginx\/conf.d\/\*.conf;\n    include \/etc\/nginx\/sites-enabled\/\*.conf;/' /etc/nginx/nginx.conf;
cat /etc/nginx/nginx.conf;
mkdir /etc/nginx/sites-available;
mkdir /etc/nginx/sites-enabled;
mkdir /usr/share/nginx/virtualhost;

wget --no-check-certificate -O /etc/nginx/sites-available/virtualhost.conf https://raw.githubusercontent.com/Kabinjp/SutorimuVPS/master/nginx-virtualhost-conf.txt;

cat /etc/nginx/sites-available/virtualhost.conf;
ln -s /etc/nginx/sites-available/virtualhost.conf /etc/nginx/sites-enabled/;

wget --no-check-certificate -O /etc/nginx/nginx.conf https://raw.githubusercontent.com/Kabinjp/SutorimuVPS/master/nginx-main-conf.txt;

wget --no-check-certificate -O /etc/nginx/conf.d/default.conf  https://raw.githubusercontent.com/Kabinjp/SutorimuVPS/master/nginx-default-conf.txt;

#wget --no-check-certificate -O /etc/nginx/conf.d/example.com.conf  https://raw.githubusercontent.com/Kabinjp/SutorimuVPS/master/nginx-custom-config-example.txt;

wget --no-check-certificate -O /etc/nginx/conf.d/my_domain https://raw.githubusercontent.com/Kabinjp/SutorimuVPS/master/nginx-my-domain-conf.txt;

wget --no-check-certificate -O /etc/nginx/fastcgi_params https://raw.githubusercontent.com/Kabinjp/SutorimuVPS/master/nginx-fastcgi-conf.txt;

rm -f /etc/nginx/conf.d/example_ssl.conf;

echo '<?php phpinfo();' | sudo tee /usr/share/nginx/virtualhost/index.php;
cp -p /etc/hosts /etc/hosts.org;
sudo sed -i -e "s/`grep 127.0.0.1 /etc/hosts`/& sutorimu.com/" /etc/hosts;

clear
        echo "----------------------------------------------------------------------------";
        echo "-------------|      PASSWORD FOR MYSQL + SERVICE START       |--------------";
        echo "-------------| _____________________________________________ |--------------";
        echo "----------------------------------------------------------------------------";
echo -e "\n";
pass1=`openssl rand 6 -base64`;
pass2="cft.${pass1}";
echo "root password is ${pass2}";

mkdir -p /www/files/ip.com/custom_error_page;
cd /www;

wget --no-check-certificate -O /www/mysql-and-sftp-password.php  https://raw.githubusercontent.com/Kabinjp/SutorimuVPS/master/nginx-mysql-password.html;

sed -i "s/SUTORIMUVPSPASSWORD/${pass2}/g" /www/mysql-and-sftp-password.php;

if [ "$arch" = "x86_64" ]; then
	if [ "$OS_MAJOR_VERSION" = 6 ]; then
mysqladmin -u root password "${pass2}";
service nginx start; chkconfig nginx on;
service mysqld start; chkconfig mysqld on;
service php-fpm start; chkconfig php-fpm on;
	else 
sudo systemctl start php-fpm;
sudo systemctl enable php-fpm;
sudo systemctl start nginx;
sudo systemctl enable nginx;
	fi
fi

clear
        echo "----------------------------------------------------------------------------";
        echo "-------------|              DOWNLOADS ERROR PAGE             |--------------";
        echo "-------------| _____________________________________________ |--------------";
        echo "----------------------------------------------------------------------------";
echo -e "\n";
wget --no-check-certificate -O /www/files/ip.com/index.html  https://raw.githubusercontent.com/Kabinjp/SutorimuVPS/master/nginx-default-index.html;
wget --no-check-certificate -O /www/files/ip.com/custom_error_page/404.html  https://raw.githubusercontent.com/Kabinjp/SutorimuVPS/master/nginx-404.html;
wget --no-check-certificate -O /www/files/ip.com/custom_error_page/403.html  https://raw.githubusercontent.com/Kabinjp/SutorimuVPS/master/nginx-403.html;
wget --no-check-certificate -O /www/files/ip.com/custom_error_page/50x.html  https://raw.githubusercontent.com/Kabinjp/SutorimuVPS/master/nginx-50x.html;

wget --no-check-certificate -O /usr/share/nginx/html/404.html  https://raw.githubusercontent.com/Kabinjp/SutorimuVPS/master/nginx-404.html;
wget --no-check-certificate -O /usr/share/nginx/html/403.html  https://raw.githubusercontent.com/Kabinjp/SutorimuVPS/master/nginx-403.html;
wget --no-check-certificate -O /usr/share/nginx/html/50x.html  https://raw.githubusercontent.com/Kabinjp/SutorimuVPS/master/nginx-50x.html;
wget --no-check-certificate -O /usr/share/nginx/html/index.html  https://raw.githubusercontent.com/Kabinjp/SutorimuVPS/master/nginx-default-index.html;

wget --no-check-certificate -O /etc/php.d/40-apcu.ini https://raw.githubusercontent.com/Kabinjp/SutorimuVPS/master/nginx-php-apcu-config.txt;

clear
        echo "----------------------------------------------------------------------------";
        echo "-------------|        INSTALL PHPMYADMIN & FILEMANAGER       |--------------";
        echo "-------------| _____________________________________________ |--------------";
        echo "----------------------------------------------------------------------------";
echo -e "\n";
#wget --no-check-certificate https://raw.githubusercontent.com/Kabinjp/SutorimuVPS/master/phpMyAdmin-4.6.6-all-languages.zip;
wget --no-check-certificate https://raw.githubusercontent.com/Kabinjp/SutorimuVPS/master/FileManager.zip;

#unzip phpMyAdmin-4.6.6-all-languages.zip;
#rm -f phpMyAdmin-4.6.6-all-languages.zip;
#mv phpMyAdmin-4.6.6-all-languages phpmyadmin.hosutingu.gq;

unzip FileManager.zip;
rm -f FileManager.zip;
sed -i "s/SUTORIMUVPSPASSWORD/${pass2}/g" /www/index.php;

#echo nginx:"${pass2}" | chpasswd;
#chown -R nginx:nginx /www;
chmod -R 777 /www/files;
#chmod +x -R /www/files/ip.com;
chmod 777 /var/lib/php/session/;
#rm -Rf phpmyadmin.hosutingu.gq;

clear
        echo "----------------------------------------------------------------------------";
        echo "-------------|       DISPLAY INFORMATION AFTER INSTALL       |--------------";
        echo "-------------| _____________________________________________ |--------------";
        echo "----------------------------------------------------------------------------";

echo -e "\n";
echo "====== Nginx + PHP-FPM + FileManager + Varnish Successfully installed";
echo "====== Website document root is /www/files/yourdomain";
echo "====== FileManager Username is sutorimu";
echo "====== FileManager Password is ${pass2}";
echo -e "\n";
echo "====== Now you can visit http://`hostname -i`/";
echo "====== FileManager: http://`hostname -i`:3083";
echo -e "\n";
echo "====== https://www.facebook.com/Jhansito18";
echo "====== Very Thank Everybody in Sutorimu Group";
#Ending script
