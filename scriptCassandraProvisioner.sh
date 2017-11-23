#!/bin/bash

install_dependencies()
{
	echo "Installing Java 1.8 (openjdk)"
	yum -y -q install java-1.8.0-openjdk java-1.8.0-openjdk-devel python-devel
	curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
	python get-pip.py
	yum -y -q install https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-4.6.2-1.x86_64.rpm
	/bin/systemctl enable grafana-server.service
	/bin/systemctl start grafana-server.service
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
yum -y -q install gcc-c++ patch readline readline-devel zlib zlib-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison iconv-devel ruby-devel libxml2 libxml2-devel libxslt libxslt-devel git
gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -sSL https://get.rvm.io | bash -s stable --ruby
#source /usr/local/rvm/scripts/rvm
gem install bundler
gem install cassandra-web
nohup cassandra-web -B 0.0.0.0:3001 &
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
