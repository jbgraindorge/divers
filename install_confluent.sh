#!/bin/bash

install_dependencies()
{
echo "Installing Java 1.8 (openjdk)"
yum -y -q install java-1.8.0-openjdk git
wget http://www.eu.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
tar xzf apache-maven-3.3.9-bin.tar.gz
mkdir /usr/local/maven
mv apache-maven-3.3.9/ /usr/local/maven/
alternatives --install /usr/bin/mvn mvn /usr/local/maven/apache-maven-3.3.9/bin/mvn 1
alternatives --config mvn
}

install_confluent()
{
	echo "Adding YUM Repo for Confluent"
	cd /etc/yum.repos.d/
	wget https://raw.githubusercontent.com/jbgraindorge/divers/master/confluent.repo
  yum clean all
	echo "Installing confluent"
	yum -y -q install confluent-platform-oss-2.11
	confluent start
	confluent stop connect

	#echo "Ensuring Cassandra starts on boot"
	#/sbin/chkconfig --add cassandra
	#/sbin/chkconfig cassandra on

	#echo "Starting Cassandra"
	#systemctl start cassandra
}

install_twitter_connector()
{
  mkdir -p /usr/local/share/kafka/plugins/
  ##INSTALL FIRST REPO
  cd /root/
  git clone https://github.com/jcustenborder/kafka-connect-twitter.git
  mv kafka-connect-twitter kafka-connect-twitter-bad
  cd kafka-connect-twitter-bad
  mvn clean package
  cp /usr/local/kafka-connect-twitter/target/kafka-connect-target/usr/share/kafka-connect/kafka-connect-twitter/* /usr/local/share/kafka/plugins/
  ##INSTALL SECOND REPO
  cd /root/
  git clone https://github.com/Eneco/kafka-connect-twitter.git
  cd kafka-connect-twitter/
  mvn clean package
  cp twitter-source.properties.example twitter-source.properties
  ##INSTALL SOME MISSING
  cd /root/
  wget http://central.maven.org/maven2/com/twitter/joauth/6.0.2/joauth-6.0.2.jar
  git clone https://github.com/twitter/hbc.git
  cd hbc
  mvn install
  echo "export CLASSPATH=/root/kafka-connect-twitter/target/kafka-connect-twitter-0.1-jar-with-dependencies.jar:/root/kafka-connect-twitter/target/:/root/kafka-connect-twitter/target/classes/:/usr/share/java/httpcomponents/httpclient.jar:/root/hbc/hbc-core/target/classes/:/root/hbc/hbc-example/target/classes/:/root/hbc" >> /root/.bashrc
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
