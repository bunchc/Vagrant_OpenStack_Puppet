sudo rpm -ivh http://yum.puppetlabs.com/el/6/products/i386/puppetlabs-release-6-7.noarch.rpm
yum update -y

yum install -y ruby1.9.1 rubygems git vim wget screen curl
echo "192.168.11.100    puppet puppetmaster.puppet.lab" >> /etc/hosts