source /vagrant/common.sh

sudo apt-get install -y puppet
sudo service puppet stop
sudo puppet agent -td --environment pod1
sudo sed -i 's/START=no/START=yes/g' /etc/default/puppet
sudo puppet agent -td --environment pod1
sudo service puppet restart
sudo puppet resource service puppet ensure=running enable=true