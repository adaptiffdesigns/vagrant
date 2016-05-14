# -*- mode: ruby -*-
# vi: set ft=ruby :
unless Vagrant.has_plugin?("vagrant-hostmanager")
    puts "This Vagrant environment requires the 'vagrant-hostmanager' plugin."
    puts "Please run `vagrant plugin install vagrant-hostmanager` and then run this command again."
    exit 1
end

PRODUCTS = {
    :apache => {
        :arch     => "x86_64",
        :box      => "ubuntu/trusty64",
        :ip       => "192.168.50.2",
        :hostname => "apache.phalconvagrant.com", # Fill in desired hostname
        :web      => "apache",
        :name     => "apache",
    },
    :nginx => {
        :arch     => "x86_64",
        :box      => "ubuntu/trusty64",
        :ip       => "192.168.50.2",
        :hostname => "nginx.phalconvagrant.com", # Fill in desired hostname
        :web      => "nginx",
        :name     => "nginx",
    },
}
# Don't touch unless you know what you're doing!

Vagrant.configure(2) do |config|
    ssh              = ENV.has_key?('SSH_PATH') ? ENV['SSH_PATH'] : 'ssh -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
    cached_addresses = {}

    # Hostmanager.
    config.hostmanager.enabled           = true
    config.hostmanager.manage_host       = true
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.include_offline   = false
    config.hostmanager.ip_resolver       = proc do |vm, resolving_vm|
        if cached_addresses[vm.name].nil?
            if hostname = (vm.ssh_info && vm.ssh_info[:host])
                vm.communicate.execute("/sbin/ip addr list | grep 'inet ' | grep 192 | egrep -o '[0-9\.]+' | head -n 1 2>&1") do |type, contents|
                    cached_addresses[vm.name] = contents.split("\n").first[/(\d+\.\d+\.\d+\.\d+)/, 1]
                end
            end
        end
        cached_addresses[vm.name]
    end

    PRODUCTS.each do |name, cfg|
        config.vm.define name do |node|
            # Base Box
            # --------------------
            node.vm.box              = cfg[:box]
            node.vm.hostname         = cfg[:name]
            node.hostmanager.aliases = [ "#{cfg[:hostname]}" ]

            # Caching.
            if Vagrant.has_plugin?("vagrant-cachier")
                node.cache.scope       = :box
                node.cache.auto_detect = false
                node.cache.enable :apt-get
            end

            # Connect to IP
            # Note: Use an IP that doesn't conflict with any OS's DHCP (Below is a safe bet)
            # --------------------
            node.vm.network "private_network", ip: cfg[:ip]

            # Forward to Port
            # --------------------
            node.vm.network :forwarded_port, guest: 3306, host: 3306, auto_correct: true

            # Optional (Remove if desired)
            # --------------------
            node.vm.provider :virtualbox do |vb|
                #vb.gui = true
                vb.customize ["modifyvm", :id, "--usb", "off"]
                vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
                vb.customize ["modifyvm", :id, "--memory", "1024"]
                vb.customize ["modifyvm", :id, "--cpus", "2"]
                vb.customize ["modifyvm", :id, "--ioapic", "on"]
                vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
                vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
            end

            # If true, agent forwarding over SSH connections is enabled
            # --------------------
            node.ssh.forward_agent = true

            # The shell to use when executing SSH commands from Vagrant
            # --------------------
            node.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

            # Synced Folders
            # --------------------
            node.vm.synced_folder ".", "/vagrant/", :mount_options => [ "dmode=777", "fmode=666" ]
            node.vm.synced_folder "./www", "/vagrant/www/", :mount_options => [ "dmode=775", "fmode=644" ], :owner => 'www-data', :group => 'www-data'

            # Provisioning Scripts
            # --------------------
            $init = <<-CONTENTS
                echo '------------------------------------------------------------init------------------------------------------------------------'
                bash /vagrant/init.sh #{cfg[:web]} '#{cfg[:hostname]}'
            CONTENTS
            $postinstall = <<-CONTENTS
                bash postinstall.sh #{cfg[:name]} "#{cfg[:hostname]}" "#{ssh}"
            CONTENTS

            node.vm.provision "init", type: "shell", inline: $init
            if Vagrant.has_plugin?("vagrant-host-shell")
                node.vm.provision "postinstall", type: "host_shell", run: 'always', inline: $postinstall
            end
        end
    end
end
