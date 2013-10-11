# -*- mode: ruby -*-
# vi: set ft=ruby :

nodes = {
    'puppet-server'   => [1, 100],
    'openstack-mysql'	=> [1, 3],
    'puppet-controller'  => [1, 4],
    'puppet-storage'	=> [1, 5],
    'puppet-compute' => [1, 200],
}

Vagrant.configure("2") do |config|
	config.vm.box = "precise64"
	config.vm.box_url = "http://files.vagrantup.com/precise64.box"
#	config.vm.synced_folder ".", "/vagrant", nfs: true
	config.vm.provider "vmware_fusion" do |v, override|
		override.vm.box = "centos_fusion"
		override.vm.box_url = "https://dl.dropbox.com/u/5721940/vagrant-boxes/vagrant-centos-6.4-x86_64-vmware_fusion.box" 
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
	                box.vm.network :private_network, ip: "192.168.11.#{ip_start+i}", :netmask => "255.255.255.0"
			box.vm.network :private_network, ip: "192.168.22.#{ip_start+i}", :netmask => "255.255.255.0"
			box.vm.network :private_network, ip: "172.16.33.#{ip_start+i}", :netmask => "255.255.255.0"
			box.vm.network :private_network, ip: "172.16.44.#{ip_start+i}", :netmask => "255.255.255.0"
	                if prefix == "puppet-server"
	                    box.vm.provision :shell, :path => "#{prefix}.sh"
	                else
	                    box.vm.provision :shell, :path => "proxy.sh"
	                end
	            end
	        end
	end
end
