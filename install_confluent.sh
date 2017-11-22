#!/bin/bash

install_dependencies()
{
	echo "Installing Java 1.8 (openjdk)"
	yum -y -q install java-1.8.0-openjdk maven git
}

install_confluent()
{
	echo "Adding YUM Repo for Confluent"
	cd /etc/yum.repos.d/
	wget https://raw.githubusercontent.com/jbgraindorge/divers/master/confluent.repo
  yum clean all
	echo "Installing confluent"
	yum -y -q install confluent-platform-oss-2.11

	#echo "Ensuring Cassandra starts on boot"
	#/sbin/chkconfig --add cassandra
	#/sbin/chkconfig cassandra on

	#echo "Starting Cassandra"
	#systemctl start cassandra
}

install_twitter_connector()
{
  cd /usr/local/
  git clone https://github.com/jcustenborder/kafka-connect-twitter.git
  cd kafka-connect-twitter
  mvn clean package
  echo "plugin.path=/usr/local/kafka-connect-twitter/target/kafka-connect-twitter-0.2-SNAPSHOT.tar.gz" >> /etc/schema-registry/connect-avro-distributed.properties
}

ensure_system_updated()
{
	#yum makecache fast

	echo "Updating Operating System"
	#yum -y -q update
}

install_dependencies
install_confluent
install_twitter_connector
ensure_system_updated
