source /vagrant/common.sh

wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb

sudo apt-get install -y puppet
sudo service puppet stop
sudo sed -i 's/START=no/START=yes/g' /etc/default/puppet
sudo puppet resource service puppet ensure=running enable=true

sudo apt-get install -y puppetmaster
sudo puppet resource service puppetmaster ensure=running enable=true
sudo echo "[pod1]" >> /etc/puppet/puppet.conf
sudo echo "manifest = /etc/puppet/manifests/site.pp" >> /etc/puppet/puppet.conf
sudo service puppetmaster restart

sudo puppet module install puppetlabs/apt

#cd /etc/puppet/modules
#git clone git://github.com/stackforge/puppet-openstack.git -b stable/grizzly openstack
#cd openstack
#sudo gem install librarian-puppet
#sudo librarian-puppet install --path ../

sudo puppet module install puppetlabs/apache --version 0.8.1
sudo puppet module install puppetlabs/openstack --version 2.1.0
#sudo puppet module install puppetlabs/openstack

sudo cat > /etc/puppet/autosign.conf <<EOF
*.puppet.lab
EOF

sudo cat > /etc/hiera.yaml <<EOF
---
:backends:
  - yaml
  - json
:hierarchy:
  - "%{::clientcert}"
  - %{environment}
  - "%{::custom_location}"
  - common
:yaml:
   :datadir: /etc/puppet/hieradata
EOF

sudo ln -s /etc/hiera.yaml /etc/puppet/hiera.yaml

# Dump our OpenStack things into Hiera
# sudo mkdir -p /etc/puppet/hieradata/
sudo mkdir -p /var/lib/hiera/
sudo mkdir -p /etc/puppet/hieradata/

#sudo cat > /var/lib/hiera/pod1.yaml <<EOF
sudo cat > /etc/puppet/hieradata/pod1.yaml <<EOF
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
openstack::compute::db_host:            %{db_host}
openstack::compute::rabbit_host:        %{db_host}
openstack::compute::keystone_host:      %{db_host}
openstack::compute::vncproxy_host:      %{db_host}
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
openstack::controller::db_host:              %{db_host}
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

\$db_host = "192.168.100.10"

node /puppet-controller/ {
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
        cinder_user_password => hiera('openstack::controller::cinder_user_password'),
        glance_user_password => hiera('openstack::controller::glance_user_password'),
        keystone_admin_token => hiera('openstack::controller::keystone_admin_token'),
        mysql_root_password  => hiera('openstack::controller::mysql_root_password'),
        nova_user_password   => hiera('openstack::controller::nova_user_password'),
        private_interface    => hiera('openstack::controller::private_interface'),
        public_address       => hiera('openstack::controller::public_address'),
        public_interface     => hiera('openstack::controller::public_interface'),
        quantum              => hiera('openstack::controller::quantum'),
        rabbit_password      => hiera('openstack::controller::rabbit_password'),
        secret_key           => hiera('openstack::controller::secret_key'),
	db_host		     => hiera('openstack::controller::db_host'),
    }
}

node /openstack-mysql/ {
	class { 'openstack::db::mysql':
	        cinder_db_password   => hiera('openstack::controller::cinder_db_password'),
	        glance_db_password   => hiera('openstack::controller::glance_db_password'),
	        keystone_db_password => hiera('openstack::controller::keystone_db_password'),
	        nova_db_password     => hiera('openstack::controller::nova_db_password'),
	        allowed_hosts        => ['127.0.0.%', '192.168.100.%'],
		mysql_root_password  => hiera('openstack::controller::mysql_root_password'),
		quantum_db_password => hiera('openstack::controller::quantum_db_password'),
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

sudo cat > /etc/puppet/manifests/mysql.pp <<EOF
#databse and rabbitmq classes

\$mysql_root_password  => hiera('openstack::controller::mysql_root_password')
\$keystone_db_password => hiera('openstack::controller::keystone_db_password')
\$glance_db_password => hiera('openstack::controller::glance_db_password')
\$nova_db_password     => hiera('openstack::controller::nova_db_password')
\$cinder_db_password => hiera('openstack::controller::cinder_db_password')
\$quantum_db_password => hiera('openstack::controller::quantum_db_password')

class openstack::db::mysql (
    # Required MySQL
    # passwords
    \$mysql_root_password,
    \$keystone_db_password,
    \$glance_db_password,
    \$nova_db_password,
    \$cinder_db_password,
    \$quantum_db_password,
    # MySQL
    \$mysql_bind_address     = '0.0.0.0',
    \$mysql_account_security = true,
    # Keystone
    \$keystone_db_user       = 'keystone',
    \$keystone_db_dbname     = 'keystone',
    # Glance
    \$glance_db_user         = 'glance',
    \$glance_db_dbname       = 'glance',
    # Nova
    \$nova_db_user           = 'nova',
    \$nova_db_dbname         = 'nova',
    # Cinder
    \$cinder                 = true,
    \$cinder_db_user         = 'cinder',
    \$cinder_db_dbname       = 'cinder',
    # quantum
    \$quantum                = true,
    \$quantum_db_user        = 'quantum',
    \$quantum_db_dbname      = 'quantum',
    \$allowed_hosts          = false,
    \$enabled                = true
) {

  # Install and configure MySQL Server
  class { 'mysql::server':
    config_hash => {
      'root_password' => \$mysql_root_password,
      'bind_address'  => \$mysql_bind_address,
    },
    enabled     => \$enabled,
  }

  # This removes default users and guest access
  if \$mysql_account_security {
    class { 'mysql::server::account_security': }
  }

  if (\$enabled) {
    # Create the Keystone db
    class { 'keystone::db::mysql':
      user          => \$keystone_db_user,
      password      => \$keystone_db_password,
      dbname        => \$keystone_db_dbname,
      allowed_hosts => \$allowed_hosts,
    }

    # Create the Glance db
    class { 'glance::db::mysql':
      user          => \$glance_db_user,
      password      => \$glance_db_password,
      dbname        => \$glance_db_dbname,
      allowed_hosts => \$allowed_hosts,
    }

    # Create the Nova db
    class { 'nova::db::mysql':
      user          => \$nova_db_user,
      password      => \$nova_db_password,
      dbname        => \$nova_db_dbname,
      allowed_hosts => \$allowed_hosts,
    }

    # create cinder db
    if (\$cinder) {
      class { 'cinder::db::mysql':
        user          => \$cinder_db_user,
        password      => \$cinder_db_password,
        dbname        => \$cinder_db_dbname,
        allowed_hosts => \$allowed_hosts,
      }
    }

    # create quantum db
    if (\$quantum) {
      class { 'quantum::db::mysql':
        user          => \$quantum_db_user,
        password      => \$quantum_db_password,
        dbname        => \$quantum_db_dbname,
        allowed_hosts => \$allowed_hosts,
      }
    }
  }
}
EOF

sudo service puppet restart
