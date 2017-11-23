#!/bin/bash

install_dependencies()
{
	echo "Installing Java 1.8 (openjdk)"
	yum -y install java-1.8.0-openjdk
}

install_cassandra()
{
	echo "Adding YUM Repo for DataStax"
	cd /etc/yum.repos.d/
	touch datastax.repo

	echo '[datastax-ddc]' >> datastax.repo
	echo 'name = DataStax Repo for Apache Cassandra' >> datastax.repo
	echo 'baseurl = http://rpm.datastax.com/datastax-ddc/3.2' >> datastax.repo
	echo 'enabled = 1' >> datastax.repo
	echo 'gpgcheck = 0' >> datastax.repo

	echo "Installing datastax-ddc"
	yum -y -q install datastax-ddc

	echo "Ensuring Cassandra starts on boot"
	/sbin/chkconfig --add cassandra
	/sbin/chkconfig cassandra on

	echo "Starting Cassandra"
	systemctl start cassandra
}

install_ruby()
{
gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
yum -y -q install gcc-c++ patch readline readline-devel zlib zlib-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison iconv-devel ruby-devel libxml2 libxml2-devel libxslt libxslt-devel git
curl -sSL https://get.rvm.io | bash -s stable --ruby
source /usr/local/rvm/scripts/rvm
gem install bundler
gem install cassandra-web
}

ensure_system_updated()
{
	yum makecache fast

	echo "Updating Operating System"
	yum -y -q update
}

install_dependencies
install_cassandra
install_ruby
ensure_system_updated
