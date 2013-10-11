source /vagrant/common.sh

# Install puppet client
sudo yum -y install puppet
sudo service puppet stop
sudo sed -i 's/START=no/START=yes/g' /etc/default/puppet
sudo puppet resource service puppet ensure=running enable=true

# Install puppet server
sudo yum -y install puppet-server
sudo puppet resource service puppetmaster ensure=running enable=true
sudo echo "[pod1]" >> /etc/puppet/puppet.conf
sudo echo "manifest = /etc/puppet/manifests/site.pp" >> /etc/puppet/puppet.conf
sudo cat > /etc/puppet/autosign.conf <<EOF
*.puppet.lab
EOF
sudo service puppetmaster restart

# Install the puppet-grizzly openstack things
sudo puppet module install puppetlabs/grizzly --version 1.0.0-rc2

sudo cp /etc/puppet/modules/grizzly/examples/common.yaml /var/lib/hiera/

sudo cat > /etc/puppet/manifests/site.pp <<EOF
node /puppet-controller-[0-9][0-9]/ {
  include ::grizzly::role::controller
}

node /puppet-storage/ {
  include ::grizzly::role::storage
}


node /puppet-compute-[0-9][0-9]/ {
  include ::grizzly::role::compute
}
EOF

sudo service iptables stop
chkconfig --level 2345 iptables off