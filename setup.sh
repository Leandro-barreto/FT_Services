#! /bin/bash

#----------------- set colors -------------------#
ORANGE="\033[0;31m "
RED="\033[0;31m "
GREEN="\033[0;92m "
CYAN="\033[0;36m "
MAGENTA="\033[0;95m "
NC="\033[0m" # No Color

echo -e "${RED}Please verify that there are 2 processors in your host${NC}"
echo -e "Press any key to continue..."
read
mkdir /home/${USER}/.kube
mkdir /home/${USER}/.docker
if [ ! "$1" == "rebuild" ]
then
	
	#------------------- docker ---------------------#

	if [ ! $(which docker) == "" ]
	then
		echo -e "${GREEN}Docker found...${NC}";
	else
		echo -e "${RED}You need Docker to run this app.${NC}";
		exit 1;
	fi

	docker ps > /dev/null;
    if [[ $? == 1 ]];
    then
        printf "${RED}Docker doesn't have the right permissions${NC}";
        sudo usermod -aG docker $USER;
        printf "${GREEN}Permissions were applied. Please log out and in again...${NC}";
        exit 1;

    fi
	#--------------- get system type ----------------#

	if [ "$(uname -s)" == "Darwin" ]
	then
		SYSTEM_TYPE="darwin"
	else
		SYSTEM_TYPE="linux"
	fi

	#----------------- kubernetes -------------------#

	if [ ! $(which kubectl) == "" ]
	then
		echo -e "${GREEN}Kubernetes found...${NC}";
	else
		echo -e "${GREEN}Downloading and installing Kubernetes...${NC}";
		if [ ${SYSTEM_TYPE} == "darwin" ]
		then
			curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/darwin/amd64/kubectl"
		else
			curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
		fi
		chmod +x ./kubectl
		sudo mv ./kubectl /usr/local/bin/kubectl
	fi
	kubectl version --client

	#------------------ minikube --------------------#

	if [ ! $(which minikube) == "" ]
	then
		echo -e "${GREEN}Minikube found...${NC}";
	else
		curl -LO "https://storage.googleapis.com/minikube/releases/latest/minikube-${SYSTEM_TYPE}-amd64"
		sudo install "minikube-${SYSTEM_TYPE}-amd64" /usr/local/bin/minikube
	fi
	VER="$(minikube version | grep -Po '(?<=minikube version: )[^\n]+')"
	if [ "$VER" == "v1.9.0" ]
	then
		echo -e "${GREEN}Updating minikube${NC}"
		curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
 		sudo install minikube-linux-amd64 /usr/local/bin/minikube
		rm -rf minikube-linux-amd64
	fi
	sudo minikube delete
	sudo apt install conntrack

	#----------- setup and permissions --------------#

	echo -e "${GREEN}Setting up permissions...${NC}"
	sudo systemctl enable docker.service
	sudo groupadd docker
	sudo usermod -aG docker $USER
	sudo chown "$USER":"$USER" /home/"$USER"/.docker -R && sudo chmod g+rwx "$HOME/.docker" -R
	sudo chown "$USER":"$USER" /home/"$USER"/.minikube -R && sudo chmod g+rwx "$HOME/.minikube" -R
	sudo chown "$USER":"$USER" /tmp -R && sudo chmod g+rwx /tmp -R
	sudo chown "$USER":"$USER" /home/"$USER"/.kube -R && sudo chmod g+rwx "$HOME/.kube" -R

	#--------------- start minikube -----------------#

	echo -e "${GREEN}Starting Minikube...${NC}"
	minikube start --driver=docker												
	                # --bootstrapper=kubeadm										\
					# --extra-config=kubelet.authentication-token-webhook=true	
	minikube addons enable metallb
	minikube addons enable metrics-server

fi

#----------------- Installing metallb -----------# 
kubectl apply -f srcs/metallb.yaml

#----------------- main config ------------------#
SYSTEM_TYPE="linux"
MYSQL_ROOT_PASSWORD="admin"
MYSQL_DATA_DIR="/data"
SSH_USER="admin"
SSH_PASS="admin"
MINIKUBE_IP="$(kubectl get node -o=custom-columns='DATA:status.addresses[0].address' | sed -n 2p)"
LOAD_IP="172.17.1.100"
WORDPRESS_DB_NAME="wordpress"
WORDPRESS_USER_NAME="root"
WORDPRESS_PASSWORD="admin"
FTP_USER="admin"
FTP_PASSWORD="admin"

#------------- duplicate raw files --------------#
#-- mysql
cp ./srcs/MySQL/srcs/mysql-raw.sql ./srcs/MySQL/srcs/mysql.sql
cp ./srcs/MySQL/srcs/setup-raw.sh ./srcs/MySQL/srcs/setup.sh
cp ./srcs/MySQL/srcs/mysql-raw.cnf ./srcs/MySQL/srcs/mysql.cnf
#-- nginx
cp ./srcs/Nginx/srcs/nginx-raw.conf ./srcs/Nginx/srcs/nginx.conf
cp ./srcs/Nginx/srcs/setup-raw.sh ./srcs/Nginx/srcs/setup.sh
cp ./srcs/Nginx/srcs/index-raw.html ./srcs/Nginx/srcs/index.html
#-- wordpress
cp ./srcs/WordPress/srcs/wp-config-raw.php ./srcs/WordPress/srcs/wp-config.php
cp ./srcs/WordPress/srcs/setup-raw.sh ./srcs/WordPress/srcs/setup.sh
cp ./srcs/WordPress/srcs/mysql-raw.sql ./srcs/WordPress/srcs/mysql.sql
cp ./srcs/WordPress/srcs/backup-raw.sql ./srcs/WordPress/srcs/backup.sql
#-- ftp
cp ./srcs/FTPS/srcs/setup-raw.sh ./srcs/FTPS/srcs/setup.sh
#-- influxdb
#-- grafana
cp ./srcs/Grafana/srcs/datasources-raw.yml ./srcs/Grafana/srcs/datasources.yml
#-- phpmyadmin
cp ./srcs/Phpmyadmin/srcs/config-raw.inc.php ./srcs/Phpmyadmin/srcs/config.inc.php
cp ./srcs/Phpmyadmin/srcs/mysql-raw.sql ./srcs/Phpmyadmin/srcs/mysql.MySQL
#-- Telegraf
cp ./srcs/Phpmyadmin/srcs/telegraf-raw.conf ./srcs/Phpmyadmin/srcs/telegraf.conf
cp ./srcs/FTPS/srcs/telegraf-raw.conf ./srcs/FTPS/srcs/telegraf.conf
cp ./srcs/Grafana/srcs/telegraf-raw.conf ./srcs/Grafana/srcs/telegraf.conf
cp ./srcs/MySQL/srcs/telegraf-raw.conf ./srcs/MySQL/srcs/telegraf.conf
cp ./srcs/Nginx/srcs/telegraf-raw.conf ./srcs/Nginx/srcs/telegraf.conf
cp ./srcs/WordPress/srcs/telegraf-raw.conf ./srcs/WordPress/srcs/telegraf.conf

#----------------- apply config -----------------#
#-- mysql
sed -i "s|__MYSQL_ROOT_PASSWORD__|${MYSQL_ROOT_PASSWORD}|g" ./srcs/MySQL/srcs/mysql.sql
sed -i "s|__MYSQL_DATA_DIR__|${MYSQL_DATA_DIR}|g" ./srcs/MySQL/srcs/setup.sh
sed -i "s|__MYSQL_DATA_DIR__|${MYSQL_DATA_DIR}|g" ./srcs/MySQL/srcs/mysql.cnf
#-- nginx
sed -i "s|__SSH_USER__|${SSH_USER}|g" ./srcs/Nginx/srcs/setup.sh
sed -i "s|__SSH_PASS__|${SSH_PASS}|g" ./srcs/Nginx/srcs/setup.sh
#-- nginx index
sed -i "s|__FTP_USER__|${FTP_USER}|g" ./srcs/Nginx/srcs/index.html
sed -i "s|__FTP_PASSWORD__|${FTP_PASSWORD}|g" ./srcs/Nginx/srcs/index.html
sed -i "s|__MYSQL_ROOT_PASSWORD__|${MYSQL_ROOT_PASSWORD}|g" ./srcs/Nginx/srcs/index.html
sed -i "s|__SSH_USER__|${SSH_USER}|g" ./srcs/Nginx/srcs/index.html
sed -i "s|__SSH_PASS__|${SSH_PASS}|g" ./srcs/Nginx/srcs/index.html
sed -i "s|__WORDPRESS_USER_NAME__|${WORDPRESS_USER_NAME}|g" ./srcs/Nginx/srcs/index.html
sed -i "s|__WORDPRESS_PASSWORD__|${WORDPRESS_PASSWORD}|g" ./srcs/Nginx/srcs/index.html
#-- wordpress
sed -i "s|__WORDPRESS_DB_NAME__|${WORDPRESS_DB_NAME}|g" ./srcs/WordPress/srcs/wp-config.php
sed -i "s|__WORDPRESS_USER_NAME__|${WORDPRESS_USER_NAME}|g" ./srcs/WordPress/srcs/wp-config.php
sed -i "s|__WORDPRESS_PASSWORD__|${WORDPRESS_PASSWORD}|g" ./srcs/WordPress/srcs/wp-config.php
sed -i "s|__MYSQL_ROOT_PASSWORD__|${MYSQL_ROOT_PASSWORD}|g" ./srcs/WordPress/srcs/setup.sh
sed -i "s|__WORDPRESS_USER_NAME__|${WORDPRESS_USER_NAME}|g" ./srcs/WordPress/srcs/mysql.sql
sed -i "s|__WORDPRESS_PASSWORD__|${WORDPRESS_PASSWORD}|g" ./srcs/WordPress/srcs/mysql.sql
sed -i "s|__WORDPRESS_DB_NAME__|${WORDPRESS_DB_NAME}|g" ./srcs/WordPress/srcs/backup.sql
sed -i "s|__LOAD_IP__|${MYSQL_IP}|g" ./srcs/WordPress/srcs/backup.sql
#-- ftps
sed -i "s|__LOAD_IP__|${LOAD_IP}|g" ./srcs/FTPS/srcs/setup.sh
sed -i "s|__FTP_USER__|${FTP_USER}|g" ./srcs/FTPS/srcs/setup.sh
sed -i "s|__FTP_PASSWORD__|${FTP_PASSWORD}|g" ./srcs/FTPS/srcs/setup.sh
#-- phpmyadmin
sed -i "s|__LOAD_IP__|${LOAD_IP}|g" ./srcs/Phpmyadmin/srcs/config.inc.php
sed -i "s|__WORDPRESS_USER_NAME__|${WORDPRESS_USER_NAME}|g" ./srcs/Phpmyadmin/srcs/mysql.sql
sed -i "s|__WORDPRESS_PASSWORD__|${WORDPRESS_PASSWORD}|g" ./srcs/Phpmyadmin/srcs/mysql.sql

#------------------- build containers and apllyng yamls ---------------------#

eval $(minikube docker-env)

echo -e "${GREEN}Building Containers... this may take a while...${NC}";
echo -e "${MAGENTA}Influxdb...${NC}";
docker build -t influxdb srcs/influxDB >& /dev/null
kubectl apply -f srcs/influxdb.yaml
while [[ $(kubectl get pods -l app=influxdb -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 3; done
sleep 10;

INFLUX_IP="$(kubectl get services influxdb -o jsonpath='{.spec.clusterIP}')"
#-- Telegraf
sed -i "s|__MINIKUBE_IP__|${INFLUX_IP}|g" ./srcs/Phpmyadmin/srcs/telegraf.conf
sed -i "s|__MINIKUBE_IP__|${INFLUX_IP}|g" ./srcs/FTPS/srcs/telegraf.conf
sed -i "s|__MINIKUBE_IP__|${INFLUX_IP}|g" ./srcs/Grafana/srcs/telegraf.conf
sed -i "s|__MINIKUBE_IP__|${INFLUX_IP}|g" ./srcs/MySQL/srcs/telegraf.conf
sed -i "s|__MINIKUBE_IP__|${INFLUX_IP}|g" ./srcs/Nginx/srcs/telegraf.conf
sed -i "s|__MINIKUBE_IP__|${INFLUX_IP}|g" ./srcs/WordPress/srcs/telegraf.conf

#-- grafana
sed -i "s|__MINIKUBE_IP__|${INFLUX_IP}|g" ./srcs/Grafana/srcs/datasources.yml

echo -e "${MAGENTA}Mysql...${NC}";
docker build -t mysql srcs/MySQL >& /dev/null
kubectl apply -f srcs/mysql.yaml
while [[ $(kubectl get pods -l app=mysql -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 10; done
sleep 10;

MYSQL_IP="$(kubectl get services mysql -o jsonpath='{.spec.clusterIP}')"
WORDPRESS_DB_HOST=$MYSQL_IP
sed -i "s|__MINIKUBE_IP__|${MYSQL_IP}|g" ./srcs/Phpmyadmin/srcs/config.inc.php
sed -i "s|__WORDPRESS_DB_HOST__|${WORDPRESS_DB_HOST}|g" ./srcs/WordPress/srcs/wp-config.php
sed -i "s|__WORDPRESS_DB_HOST__|${WORDPRESS_DB_HOST}|g" ./srcs/WordPress/srcs/setup.sh


echo -e "${MAGENTA}Wordpress...${NC}";
docker build -t wordpress srcs/WordPress >& /dev/null
kubectl apply -f srcs/wordpress.yaml
while [[ $(kubectl get pods -l app=wordpress -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 3; done
sleep 1;
echo -e "${MAGENTA}Ftp...${NC}";
docker build -t ftps srcs/FTPS >& /dev/null
kubectl apply -f srcs/ftps.yaml
while [[ $(kubectl get pods -l app=ftps -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 3; done
sleep 1;
echo -e "${MAGENTA}Grafana...${NC}";
docker build -t grafana srcs/Grafana >& /dev/null
kubectl apply -f srcs/grafana.yaml
while [[ $(kubectl get pods -l app=grafana -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 3; done
sleep 1;
echo -e "${MAGENTA}Phpmyadmin...${NC}";
docker build -t phpmyadmin srcs/Phpmyadmin >& /dev/null
kubectl apply -f srcs/phpmyadmin.yaml
while [[ $(kubectl get pods -l app=phpmyadmin -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 3; done
sleep 1;

WP_IP="$(kubectl get services wordpress -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
PHP_IP="$(kubectl get services phpmyadmin -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
FTP_IP="$(kubectl get services ftps -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
GRAF_IP="$(kubectl get services grafana -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
sed -i "s|__LOAD_IP__|${LOAD_IP}|g" ./srcs/Nginx/srcs/index.html
sed -i "s|__MINIKUBE_IP__|${MINIKUBE_IP}|g" ./srcs/Nginx/srcs/index.html
sed -i "s|__WP_IP__|${WP_IP}|g" ./srcs/Nginx/srcs/index.html
sed -i "s|__PHP_IP__|${PHP_IP}|g" ./srcs/Nginx/srcs/index.html
sed -i "s|__FTP_IP__|${FTP_IP}|g" ./srcs/Nginx/srcs/index.html
sed -i "s|__GRAF_IP__|${GRAF_IP}|g" ./srcs/Nginx/srcs/index.html

echo -e "${MAGENTA}Nginx...${NC}";
docker build -t nginx srcs/Nginx >& /dev/null
kubectl apply -f srcs/nginx.yaml
while [[ $(kubectl get pods -l app=nginx -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 4; done
sleep 10;

#------------------- remove temps --------------------#
#-- mysql
rm ./srcs/MySQL/srcs/mysql.sql
rm ./srcs/MySQL/srcs/setup.sh
rm ./srcs/MySQL/srcs/mysql.cnf
#-- nginx
rm ./srcs/Nginx/srcs/setup.sh
rm ./srcs/Nginx/srcs/index.html
#-- wordpress
rm ./srcs/WordPress/srcs/wp-config.php
rm ./srcs/WordPress/srcs/setup.sh
rm ./srcs/WordPress/srcs/mysql.sql
rm ./srcs/WordPress/srcs/backup.sql
#-- phpmyadmin
rm ./srcs/Phpmyadmin/srcs/config.inc.php

echo -e "${GREEN}Starting Dashboard...${NC}";

minikube dashboard
