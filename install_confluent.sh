#!/bin/bash

install_dependencies()
{
	echo "Installing Java 1.8 (openjdk)"
	yum -y install java-1.8.0-openjdk
}

install_confluent()
{
	echo "Adding YUM Repo for Confluent"
	cd /etc/yum.repos.d/
	wget https://raw.githubusercontent.com/jbgraindorge/divers/master/confluent.repo
  yum clean all
	echo "Installing confluent"
	yum -y install confluent-platform-oss-2.11

	#echo "Ensuring Cassandra starts on boot"
	#/sbin/chkconfig --add cassandra
	#/sbin/chkconfig cassandra on

	#echo "Starting Cassandra"
	#systemctl start cassandra
}

ensure_system_updated()
{
	#yum makecache fast

	echo "Updating Operating System"
	#yum -y -q update
}

install_dependencies
install_confluent
ensure_system_updated
