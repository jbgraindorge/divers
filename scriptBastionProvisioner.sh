#!/bin/bash

cat >> /home/ubuntu/.bashrc <<\EOF
export ANSIBLE_FORKS=10
export ANSIBLE_HOST_KEY_CHECKING=false
export ANSIBLE_CONFIG=/home/ubuntu/ansible-hadoop/ansible.cfg
export ANSIBLE_HOSTS=/home/ubuntu/ansible-hadoop/inventory/static
EOF

# Install dependencies
apt-get update
apt-get -y install \
  python-virtualenv \
  python-pip \
  python-dev \
  libffi-dev \
  libssl-dev \
  ntp \
  git \
  vim

cd /home/ubuntu

mkdir -p /home/ubuntu/.ssh
chmod 700 /home/ubuntu/.ssh
chown -R ubuntu: /home/ubuntu/.ssh
# Generate private key
#cat > /home/ubuntu/.ssh/id_rsa <<\EOF
#${ssh_private_key}
#EOF

chmod 600 /home/ubuntu/.ssh/id_rsa
chown -R ubuntu: /home/ubuntu/

# Install Ansible
virtualenv .venv
source .venv/bin/activate
pip install -U pip
pip install -U setuptools
pip install markupsafe ansible requests

# Setup Ansible playbook
#git clone https://github.com/rackerlabs/ansible-hadoop
git clone https://github.com/jbgraindorge/ansible-hadoop

###HOSTS
#cat > /tmp/hosts <<\EOF
#127.0.0.1 localhost
# The following lines are desirable for IPv6 capable hosts
#::1 ip6-localhost ip6-loopback
#fe00::0 ip6-localnet
#ff00::0 ip6-mcastprefix
#ff02::1 ip6-allnodes
#ff02::2 ip6-allrouters
#ff02::3 ip6-allhosts
#EOF


cat >> /home/ubuntu/.ssh/config  <<\EOF
Host *
    StrictHostKeyChecking no
EOF


cat > /home/ubuntu/ansible-hadoop/inventory/static <<\EOF
[master-nodes]
10.0.1.55 ansible_ssh_user=ubuntu ansible_python_interpreter=/usr/bin/python3
10.0.1.56 ansible_ssh_user=ubuntu ansible_python_interpreter=/usr/bin/python3
[slave-nodes]
10.0.1.65 ansible_ssh_user=ubuntu ansible_python_interpreter=/usr/bin/python3
10.0.1.66 ansible_ssh_user=ubuntu ansible_python_interpreter=/usr/bin/python3
10.0.1.67 ansible_ssh_user=ubuntu ansible_python_interpreter=/usr/bin/python3
EOF

ansible all -b -m copy -a "src=/tmp/hosts dest=/etc/hosts"

cat > /home/ubuntu/ansible-hadoop/playbooks/group_vars/master-nodes <<\EOF
cluster_interface: 'eth0'
EOF

cat > /home/ubuntu/ansible-hadoop/playbooks/group_vars/slave-nodes <<\EOF
cluster_interface: 'eth0'
datanode_disks: ['/dev/xvdf', '/dev/xvdg', '/dev/xvdh']
EOF

cat > /home/ubuntu/ansible-hadoop/playbooks/group_vars/all <<\EOF
---
cluster_name: 'hdp-cluster'
distro: 'hdp'
hdp_version: '2.6'
admin_password: '${admin_password}'
services_password: '${services_password}'
# set to true to show host variables
debug: true
EOF


sed -i \
  "s@\(8080/api/v1/hosts/{{\).*\( | lower }}\)@\1 hostvars[item]['ansible_fqdn']\2@" \
  /home/ubuntu/ansible-hadoop/playbooks/roles/ambari-server/tasks/prerequisites.yml

sed -i \
  "s@\['ansible_nodename'\] | lower@['ansible_fqdn'] | lower@" \
  /home/ubuntu/ansible-hadoop/playbooks/roles/ambari-server/templates/cluster-template-multi-nodes.j2

sed -i \
  -e 's/^arcadia: .*/arcadia: false/' \
  -e "s/^cluster_name: .*/cluster_name: 'hdp-cluster'/" \
  -e "s/^ambari_version: .*/ambari_version: '2.5.2.0'/" \
  -e "s/^admin_password: .*/admin_password: '${admin_password}'/" \
  -e "s/^services_password: .*/services_password: '${services_password}'/" \
  /home/ubuntu/ansible-hadoop/playbooks/group_vars/hortonworks

chown -R ubuntu: /home/ubuntu/
