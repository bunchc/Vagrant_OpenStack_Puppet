source /vagrant/common.sh
sudo yum install puppet
sudo service puppet stop
sudo puppet agent -td 
sudo service puppet restart

sudo puppet resource service puppet ensure=running enable=true