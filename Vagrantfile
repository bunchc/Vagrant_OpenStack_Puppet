# -*- mode: ruby -*-
# vi: set ft=ruby :

nodes = {
    'puppet-server'   => [1, 100],
    'openstack-mysql'	=> [1,10],
    'puppet-controller'  => [2, 101],
    'puppet-compute' => [3, 200],
}

Vagrant.configure("2") do |config|
	config.vm.box = "precise64"
	config.vm.box_url = "http://files.vagrantup.com/precise64.box"
	config.vm.synced_folder ".", "/vagrant", nfs: true
	config.vm.provider "vmware_fusion" do |v, override|
		override.vm.box = "precise64_fusion"
		override.vm.box_url = "http://grahamc.com/vagrant/ubuntu-12.04.2-server-amd64-vmware-fusion.box"
	end
    
	nodes.each do |prefix, (count, ip_start)|
        	count.times do |i|
	            if prefix == "puppet-compute" || prefix == "puppet-controller"
	                hostname = "%s-%02d" % [prefix, (i+1)]
	            else
	                hostname = "%s" % [prefix, (i+1)]
	            end
            
	            config.vm.define "#{hostname}" do |box|
	                box.vm.hostname = "#{hostname}.puppet.lab"
	                box.vm.network :private_network, ip: "192.168.100.#{ip_start+i}", :netmask => "255.255.255.0" 
	                if prefix == "puppet-server"
	                    box.vm.provision :shell, :path => "#{prefix}.sh"
	                else
	                    box.vm.provision :shell, :path => "proxy.sh"
	                end
	            end
	        end
	end
end
