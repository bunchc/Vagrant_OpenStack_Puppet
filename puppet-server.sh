source /vagrant/common.sh

sudo apt-get install -y puppet
sudo service puppet stop
sudo sed -i 's/START=no/START=yes/g' /etc/default/puppet
sudo puppet resource service puppet ensure=running enable=true

sudo apt-get install -y puppetmaster
sudo puppet resource service puppetmaster ensure=running enable=true
sudo service puppetmaster restart

sudo puppet module install puppetlabs/apt
sudo puppet module install puppetlabs/openstack

sudo cat > /etc/puppet/autosign.conf <<EOF
*.puppet.lab
EOF

sudo cat > /etc/hiera.yaml <<EOF
---
:backends:
  - yaml
  - json
:yaml:
  :datadir: /etc/puppet/hieradata
:json:
  :datadir: /etc/puppet/hieradata
:hierarchy:
  - "%{::clientcert}"
  - "%{::custom_location}"
  - common
EOF

# Dump our OpenStack things into Hiera
# sudo mkdir -p /etc/puppet/hieradata/
sudo mkdir -p /var/lib/hiera/

#sudo cat > /etc/puppet/hieradata/common.yaml <<EOF
sudo cat > /var/lib/hiera/common.yaml <<EOF
---
# Data needed for Class['openstack::compute']

# The IP and interface that external sources will use to communicate with the instance and hypervisors.
openstack::compute::public_interface:   'eth0'
openstack::compute::internal_address:   "%{ipaddress_eth0}"
openstack::compute::iscsi_ip_address:   "%{ipaddress_eth0}"

# The interface that will handle instance to intance communication and instance outbound traffic.
openstack::compute::private_interface:  'eth1'

# It most all cases the libvirt_type will be kvm for production clusters.
openstack::compute::libvirt_type:       'qemu'

# This adds networking deamon so that we remove single points of failure.
openstack::compute::multi_host:         true

# IP or hostname of the controller node
openstack::compute::db_host:            '192.168.100.101'
openstack::compute::rabbit_host:        '192.168.100.101'
openstack::compute::keystone_host:      '192.168.100.101'
openstack::compute::vncproxy_host:      '192.168.100.101'
openstack::compute::glance_api_servers: '192.168.100.101:9292'

# An IP address range tha Openstack can use for distributing internal DHCP addresses.
openstack::compute::fixed_range:        '192.168.101.0/24'

# Password and users for the plumbing components of Openstack.
openstack::compute::nova_user_password: 'qr9A2mzc)@C&4wQ'
openstack::compute::nova_db_password:   '4g#Xzfv8%*GA4Wv'
openstack::compute::cinder_db_password: '4g#Xzfv8%*GA4Wv'
openstack::compute::rabbit_password:    'RYiTg4{f8e2*{hL'

# VNC is helpful for troubleshooting but not all cloud images allow you to login via a console.
openstack::compute::vnc_enabled:        true

# Verbose just makes life easier.
openstack::compute::verbose:            true

# The quantum module wasn't ready at time of release of the openstack module.
openstack::compute::quantum:           false


# Data needed for Clas['openstack::controller']

# The IP and interface that external sources will use to communicate with the instance and hypervisors.
openstack::controller::public_address:       "%{ipaddress_eth0}"
openstack::controller::public_interface:     'eth0'

# The interface that will handle instance to intance communication and instance outbound traffic.
openstack::controller::private_interface:    'eth1'

# The initial admin account created by Puppet.
openstack::controller::admin_email:          admin@example.com
openstack::controller::admin_password:       '.F}k86U4PG,TcyY'

# The initial region this controller will manage.
openstack::controller::region:               'region-one'

# Password and users for the plumbing components of Openstack.
openstack::controller::mysql_root_password:  'B&6p,JoC4B%2CJo'
openstack::controller::keystone_db_password: '4g#Xzfv8%*GA4Wv'
openstack::controller::keystone_admin_token: '$9*uKaa3mdn7eQMVoGVBKwZ+C'
openstack::controller::glance_db_password:   '4g#Xzfv8%*GA4Wv'
openstack::controller::glance_user_password: 'qr9A2mzc)@C&4wQ'
openstack::controller::nova_db_password:     '4g#Xzfv8%*GA4Wv'
openstack::controller::nova_user_password:   'qr9A2mzc)@C&4wQ'
openstack::controller::cinder_db_password:   '4g#Xzfv8%*GA4Wv'
openstack::controller::cinder_user_password: 'qr9A2mzc)@C&4wQ'
openstack::controller::secret_key:           'LijkVnU9bwGmUhnLBZvuB49hAETfQ(M,hg*AYoxcxcj'
openstack::controller::rabbit_password:      'RYiTg4{f8e2*{hL'

# The memcache, DB, and glance hosts are the controller node so just talk to them over localhost.
openstack::controller::db_host:              '127.0.0.1'
openstack::controller::db_type:              'mysql'
openstack::controller::glance_api_servers:
   - '127.0.0.1:9292'
openstack::controller::cache_server_ip:      '127.0.0.1'
openstack::controller::cache_server_port:    '11211'

# An IP address range that Openstack can use for distributing internal DHCP addresses.
openstack::controller::fixed_range:          '192.168.101.0/24'

# An IP address range that Openstack can use for assigning "publicly" accesible IP addresses.  In a simple case this can  be a subset of the IP subnet that you put your public interface on, e.g. 10.0.0.1/23 and 10.0.1.1/24.
openstack::controller::floating_range:       '10.0.0.1/24'

# This adds networking deamon so that we remove single points of failure.
openstack::controller::multi_host:           true

# Verbose just makes life easier.
openstack::controller::verbose:              true

# The quantum module wasn't ready at time of release of the openstack module.
openstack::controller::quantum:              false

# Data needed for Class['openstack::auth_file']
openstack::auth_file::admin_password:       '.F}k86U4PG,TcyY'
openstack::auth_file::keystone_admin_token: '$9*uKaa3mdn7eQMVoGVBKwZ+C'
openstack::auth_file::controller_node:      '127.0.0.1'
EOF

# Make a site.pp using the Hiera stuffs
cat > /etc/puppet/manifests/site.pp <<EOF
node /puppet-controller.puppet.lab/ {
    class { 'openstack::repo::uca':
        release => 'grizzly',
    }
 
    class { 'openstack::auth_file':
        admin_password       => hiera('openstack::auth_file::admin_password'),
        keystone_admin_token => hiera('openstack::auth_file::keystone_admin_token'),
        controller_node      => hiera('openstack::auth_file::controller_node'),
    } 
 
    class { 'openstack::controller':
        admin_email          => hiera('openstack::controller::admin_email'),
        admin_password       => hiera('openstack::controller::admin_password'),
        allowed_hosts        => ['127.0.0.%', '192.168.100.%'],
        cinder_db_password   => hiera('openstack::controller::cinder_db_password'),
        cinder_user_password => hiera('openstack::controller::cinder_user_password'),
        glance_db_password   => hiera('openstack::controller::glance_db_password'),
        glance_user_password => hiera('openstack::controller::glance_user_password'),
        keystone_admin_token => hiera('openstack::controller::keystone_admin_token'),
        keystone_db_password => hiera('openstack::controller::keystone_db_password'),
        mysql_root_password  => hiera('openstack::controller::mysql_root_password'),
        nova_db_password     => hiera('openstack::controller::nova_db_password'),
        nova_user_password   => hiera('openstack::controller::nova_user_password'),
        private_interface    => hiera('openstack::controller::private_interface'),
        public_address       => hiera('openstack::controller::public_address'),
        public_interface     => hiera('openstack::controller::public_interface'),
        quantum              => hiera('openstack::controller::quantum'),
        rabbit_password      => hiera('openstack::controller::rabbit_password'),
        secret_key           => hiera('openstack::controller::secret_key'),
    }
}

node /puppet-compute/ {
    class { 'openstack::repo::uca':
        release => 'grizzly',
    }
 
    class { 'openstack::compute':
        public_interface    => hiera('openstack::compute::public_interface'),
        internal_address    => hiera('openstack::compute::internal_address'),
        iscsi_ip_address    => hiera('openstack::compute::iscsi_ip_address'),
        private_interface   => hiera('openstack::compute::private_interface'),
        libvirt_type        => hiera('openstack::compute::libvirt_type'),
        multi_host          => hiera('openstack::compute::multi_host'),
        db_host             => hiera('openstack::compute::db_host'),
        rabbit_host         => hiera('openstack::compute::rabbit_host'),
        keystone_host       => hiera('openstack::compute::keystone_host'),
        vncproxy_host       => hiera('openstack::compute::vncproxy_host'),
        glance_api_servers  => hiera('openstack::compute::glance_api_servers'),
        fixed_range         => hiera('openstack::compute::fixed_range'),
        nova_user_password  => hiera('openstack::compute::nova_user_password'),
        nova_db_password    => hiera('openstack::compute::nova_db_password'),
        cinder_db_password  => hiera('openstack::compute::cinder_db_password'),
        rabbit_password     => hiera('openstack::compute::rabbit_password'),
    }
}
EOF

sudo service puppet restart