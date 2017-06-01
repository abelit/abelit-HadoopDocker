#! /bin/bash

#===============================================================================================
#   System Required:  Linux/Unix-Like and MacOSX
#   Version: 3.1415
#   Modified: 2017-05-24
#   Author: Abelit <ychenid@live.com>
#   Description: Build Hadoop and Spark Cluster Based on CentOS and Ubuntu 16.04
#   Intro: http://www.dockertime.com
#===============================================================================================

# Set shell environment
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
# clear

# Define variable --------------Begin---------------------
# Check system information
osname=`uname -s`

# Define hadoop and spark's path
local_path=`pwd`

# Define docker image name or tag
hadoop_image="ubuntu:test"

# Define datanode or slaves node numbers
node_num=3

# Parameter of this script
param=$1

# Define hadoop and its conf's path on local
hadoop_path="$local_path/hadoop"
hadoop_hdfs_path="$hadoop_path/data/hdfs"
hadoop_conf_path="$hadoop_path/etc/hadoop"
hadoop_conf_slaves="$hadoop_conf_path/slaves"
hadoop_conf_coresite="$hadoop_conf_path/core-site.xml"
hadoop_conf_hdfssite="$hadoop_conf_path/hdfs-site.xml"
hadoop_conf_mapredsite="$hadoop_conf_path/mapred-site.xml"
hadoop_conf_yarnsite="$hadoop_conf_path/yarn-site.xml"
hadoop_conf_hadoopenv="$hadoop_conf_path/hadoop-env.sh"
hadoop_conf_mapredenv="$hadoop_conf_path/mapred-env.sh"
hadoop_conf_yarnenv="$hadoop_conf_path/yarn-env.sh"

# Define spark and its conf's path
spark_path="$local_path/spark"
spark_conf_path="$spark_path/conf"
spark_conf_env="$spark_conf_path/spark-env.sh"
spark_conf_slaves="$spark_conf_path/slaves"

# Define file known_hosts and its path
server_path="$local_path/server"
server_conf_path="$server_path/etc"
server_conf_hosts="$server_conf_path/hosts"
server_conf_bashrc="$server_conf_path/bash.bashrc"

# Define file known_hosts and its path
container_server_conf_hosts="/etc/hosts"
container_server_conf_bashrc="/etc/bash.bashrc"

# Define hadoop and its conf's path on the container
container_hadoop_path="/root/bigdata/hadoop"
container_hadoop_hdfs_path=$container_hadoop_path/hdfs
container_hadoop_conf_path=$container_hadoop_path/etc/hadoop

# Define spark and its conf's path on the container
container_spark_path="/root/bigdata/spark"
container_spark_conf_path=$container_spark_path/conf
# Define variable --------------End----------------------


# Configure soft path environment
function addPath() {
		# Check container's path
		if [ -d "$server_conf_path" ];then
			if [ ! -e "$server_conf_hosts" ];then
				touch $server_conf_hosts
			fi
		else
			mkdir  -p $server_conf_path
			touch $server_conf_hosts
		fi
}

# Make sure only root can run this script
function isRoot() {
	if [[ $EUID -ne 0 ]]; then
		echo "Error:This script must be run as root!" 1>&2
		exit 1
	fi
}

# Make sure the docker has been installed
function isDocker() {
	dk=`which docker`
	if [[ "$dk" = "" ]];then
		echo "Warnning: !! No docker service installed on your system."
		echo "Now docker service will be installed on your system,please install docker before executing this script ..."
		exit 1
	else
		# Check version of docker
		dkversion=`docker -v`
		echo "$dkversion has been installed."
	fi
}


# Start docker service
function startDocker() {
	isrun=`docker ps -a`
	if [[ ! -n "$isrun" ]]; then
		if [[ "$osname" = "Linux" ]];then
			echo "You are using Linux OS, the linux kernerl is `uname -rp`."
			echo "Now starting docker service..."
			systemctl restart docker.service
		elif [[ "$osname" = "Darwin" ]]; then
			echo "You are using MacOSX, please start docker service by manual."
			exit 1
		else
			echo "The script is noly running based on Linux/Unix-Like system. Please make sure your system is Linux/Unix-Like."
			exit 1
	  fi
	else
		echo "Docker is running."
	fi
}

function startMaster() {
	master_container='master'
	#Start a master hadoop container
	docker run -t -d --name master -h master -v $server_conf_bashrc:$container_server_conf_bashrc -v $server_conf_hosts:$container_server_conf_hosts -v $hadoop_conf_path:$container_hadoop_conf_path -v $hadoop_hdfs_path/$master_container:$container_hadoop_hdfs_path $hadoop_image
	master_ip=$(docker inspect --format='{{.NetworkSettings.IPAddress}}' $master_container)

	echo ""
	echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "The namenode(master) has been started."
	echo "The name of container:${master_container}."
	echo "The IPAddress: ${master_ip}"
	echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo ""
	echo "$master_ip    $master_container" >> $server_conf_hosts
}

function startSlave() {
	#Start some slave hadoop container (Datanode/Slaves)
	echo "Please the number of Datanode that you want to build: "
	read -p "(Default will create $node_num datanodes):" number

	if [ "$number" = "" ];then
		number=$node_num
	fi

	# Clearing hadoop slaves
	sed -ie '/^slave.*/d' $hadoop_conf_slaves
	sed -ie '/^$/d' $hadoop_conf_slaves
	# Clearing spark slaves
	sed -ie '/^slave.*/d' $spark_conf_slaves
	sed -ie '/^$/d' $spark_conf_slaves

	while [ $number -gt 0 ]
	do
		slave_container="slave${number}"
		# Configuring hadoop slaves configuration
		echo $slave_container >> $hadoop_conf_slaves

		# Configuring hadoop slaves configuration
		echo $slave_container >> $spark_conf_slaves

		docker run -t -d --name slave${number} -h slave${number} -v $server_conf_bashrc:$container_server_conf_bashrc -v $server_conf_hosts:$container_server_conf_hosts -v $hadoop_conf_path:$container_hadoop_conf_path -v $hadoop_hdfs_path/slave${number}:$container_hadoop_hdfs_path $hadoop_image
		slave_ip=$(docker inspect --format='{{.NetworkSettings.IPAddress}}' $slave_container)

		echo ""
		echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		echo "The datanode slave${number} has been started."
		echo "The name of container:${slave_container}."
		echo "The IPAddress: ${slave_ip}"
		echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		echo ""
		echo "$slave_ip    $slave_container" >> $server_conf_hosts
		number=$[ $number-1 ]
	done
}

#Use Hadoop
function enterContainer(){
	echo "Now you can go to the node of hadoop. Default you will go to the master node."
	echo "If you don't know which node you have started and you can input 'node' to show."
	echo "Please input the name of node you will go to:"
	read -p "(Default is master node.):" node
	if [ "$node" = "" ];then
		node='master'
	else
		if [ "$node" = "node" ];then
			container_lists="`docker ps | grep -E "slave|master|secondarynamenode" | awk '{print $NF}'`"
			echo $container_lists
			enterContainer
		fi
		node=$node
	fi
	# Using node by interactive
	docker exec -it $node /bin/bash
}

#Reset Docker Parameters
function resetDocker() {
	# Clear known_hosts contents
	echo "Clear hosts contents ..."
	cat /dev/null > $server_conf_hosts

	container_lists="`docker ps | grep -E "slave|master|secondarynamenode" | awk '{print $NF}'`"
	for container_name in $container_lists
	do
		echo "Stopping Container $container_name ..."
		docker stop $container_name
		echo "The Hadoop Node $container_name has been stoped! "
	done

	#Romove Container
	container_lists="`docker ps -a | grep -E "slave|master|secondarynamenode" | awk '{print $NF}'`"
	for container_name in $container_lists
	do
		echo "Removing Container $container_name ..."
		docker rm $container_name
		echo "The Hadoop Node $container_name has been removed! "
	done
}

# Check the status of container
function checkContainer() {
	container_running_lists="`docker ps | grep -E "slave|master|secondarynamenode"`"
	container_exist_lists="`docker ps -a | grep -E "slave|master|secondarynamenode"`"
	if [ "$container_running_lists" != "" ];then
		#Running
		echo "There have some running hadoop container."
		echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		docker ps | grep -E "slave|master|secondarynamenode"
		echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		echo ""
	else
		echo "No hadoop container is running."
	fi

	if [ "$container_exist_lists" != "" ];then
		#Running
		echo "There have some created hadoop container."
		echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		docker ps -a | grep -E "slave|master|secondarynamenode"
		echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		echo ""
	else
		echo "No hadoop container exists."
	fi
}

#SSH Configuration in the container
# function sshConf() {
# 	container_lists="`docker ps | grep -E "slave|master|secondarynamenode" | awk '{print $NF}'`"
# 	for container in $container_lists
# 	do
# 		container_ip=$(docker inspect --format='{{.NetworkSettings.IPAddress}}' $container)
# 		known_hosts="$container,$container_ip"
# 		known_hosts=$known_hosts" ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBNhSjuhiLxYqNBQPnwUKQJlPfs/lqHPGwMxcT5D9saXXZ6gb75f22Yn1ClRmktzh29vOziEMCMgm3iOiQ/UOdak="
# 		echo $known_hosts >> $container_known_hosts
# 	done
# }

function logo() {
	#Make Symble Start
	echo " HH    HH       AA        DDDDDD    OOOOOOOO OOOOOOOO PPPPPPPP "
	echo " HH    HH      AA AA      DD    DD  OO    OO OO    OO PP    PP "
	echo " HH    HH     AA   AA     DD     DD OO    OO OO    OO PP    PP "
	echo " HHHHHHHH    AAAAAAAAA    DD     DD OO    OO OO    OO PPPPPPPP "
	echo " HH    HH   AA       AA   DD     DD OO    OO OO    OO PP       "
	echo " HH    HH  AA         AA  DD    DD  OO    OO OO    OO PP       "
	echo " HH    HH AA           AA DDDDDD    OOOOOOOO OOOOOOOO PP       "
}

function author() {
	# Show author's info.
	echo "Welcome to use hadoop built on docker container! Good luck for you!"
	echo "########################################################################"
	echo "# Build Hadoop Cluster and Spark Based on Linux/Unix-Like and MacOSX   #"
	echo "# Version:3.1415                                                       #"
	echo "# Author: Abelit <ychenid@live.com>                                    #"
	echo "# Intro: http://www.dockertime.com                                     #"
	echo "#                                                                      #"
	echo "########################################################################"
	echo ""
}

function sucessInfo() {
	#Show Result of Installation
	echo ""
	echo "*******************************************************************************************"
	echo "*******************************************************************************************"
	echo "Congradulations! Hadoop Cluster has been Built and Insltalled successfully. "
	echo "*******************************************************************************************"
	echo "*******************************************************************************************"
	echo ""
}

#Run Hadoop Container
function startContainer() {
	# echo "Verifing privilege of the user ..."
	# isRoot
	echo "Checking docke package ..."
	isDocker
	echo "Creating prerequirements directories ..."
	addPath
	echo "Starting docker engine ..."
	sleep 2
	startDocker
	echo "Starting container ..."
	startMaster
	startSlave
	# echo "Conguring ssh ..."
	# sshConf
	# echo "Restarting dns ..."
	# restartDNS
	echo "All services are started successfully."
	sucessInfo
	enterContainer
}

#The Header Information
function startup() {
	author
	logo
	echo ""

	echo "This shell script will build hadoop cluster based on the virtulization of docker:"
	echo ""
	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!Notice!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "There maybe have some container you have ever created.And you should "
	echo "clear and remove them before build new container."
	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!Notice!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

	echo "1. Clear and Remove Hadoop Container all that have been created!"
	echo "2. Build Hadoop Cluster Using Docker. "
	echo "3. Look up created or running Hadoop Container."
	echo "4. Enter into container to manage it."
	echo "Others to Exit. "
	echo "Please input the number:"
	read num
	case "${num}" in
	[1] ) (resetDocker);;
	[2] ) (startContainer);;
	[3] ) (checkContainer);;
	[4] ) (enterContainer);;
	 *  ) echo "Nothing you will do.";;
	esac
}

function manPage() {
	echo "-h or --help : Lookup help information and usage."
	echo ""
}

startup
