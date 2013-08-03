export DEBIAN_FRONTEND=noninteractive
echo 'Acquire::http { Proxy "http://'162.209.50.108:3142'"; };' | sudo tee /etc/apt/apt.conf.d/01apt-cacher-ng-proxy
apt-get update && apt-get install -y vim wget curl git

wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb
dpkg -i puppetlabs-release-precise.deb
apt-get update

sudo apt-get install -y ruby1.9.1 rubygems
sudo gem install rmate
echo "192.168.100.100    puppet puppetmaster.puppet.lab" >> /etc/hosts