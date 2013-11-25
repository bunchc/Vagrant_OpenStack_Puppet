# -*- mode: ruby -*-
# vi: set ft=ruby :

nodes = {
    'puppet-server'   => [1, 100],
    'puppet-controller'  => [1, 101],
    'puppet-compute' => [3, 200],
}

Vagrant.configure("2") do |config|
    config.vm.box = "precise64"
    nodes.each do |prefix, (count, ip_start)|
        count.times do |i|
            if prefix == "puppet-compute"
                hostname = "%s-%02d" % [prefix, (i+1)]
            else
                hostname = "%s" % [prefix, (i+1)]
            end
            
            config.vm.define "#{hostname}" do |box|
                box.vm.hostname = "#{hostname}.puppet.lab"
                box.vm.network :private_network, ip: "192.168.100.#{ip_start+i}", :netmask => "255.255.255.0" 
                #box.vm.network :private_network
                if prefix == "puppet-server"
                    box.vm.provision :shell, :path => "#{prefix}.sh"
                else
                    box.vm.provision :shell, :path => "proxy.sh"
                end
            end
        end
    end
end
