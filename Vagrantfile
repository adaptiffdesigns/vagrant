# -*- mode: ruby -*-
# vi: set ft=ruby :
require './requirements.rb'
require './boxes.rb'

# Don't touch unless you know what you're doing!

Vagrant.configure("2") do |config|
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

    # SSH settings.
    config.ssh.username      = "root"
    config.ssh.password      = "vagrant"
    config.ssh.forward_agent = true
    if File.exists?(KEYS.private)
        config.ssh.private_key_path = [ KEYS.private ]
    end

    PRODUCTS.each do |name, cfg|
        config.vm.define name do |node|
            # Variables.
            node.vm.box              = cfg[:box]
            node.vm.hostname         = cfg[:name]
            node.hostmanager.aliases = [ "#{cfg[:hostname]}" ]

            # Caching.
            if Vagrant.has_plugin?("vagrant-cachier")
                node.cache.scope       = :box
                node.cache.auto_detect = false
                node.cache.enable :yum
            end

            # Network Settings.
            node.vm.network "private_network", ip: cfg[:ip]
            #node.vm.network "public_network"

            # Virtualbox specific.
            node.vm.provider :virtualbox do |vbox|
                #vbox.gui = true
                vbox.customize ["modifyvm", :id, "--name", cfg[:name]]
                vbox.customize ["modifyvm", :id, "--usb", "off"]
                vbox.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
                vbox.customize ["modifyvm", :id, "--memory", "512"]
            end

            # Setup folder mounting.
            node.vm.synced_folder ".", "/vagrant"

            # Start the box up.
            $config = <<-CONTENTS
            # Setup fastestmirror plugin
            INSTALLED=$(yum list installed --disablerepo='*' --enablerepo='sl' yum-plugin-fastestmirror 2>&1)
            if [ "$?" != "0" ]; then
                yum install -y -q --disablerepo="*" --enablerepo="sl" yum-plugin-fastestmirror
                if [ -d /etc/yum.repos.d ]; then
                    sed -i 's/^#mirrorlist/mirrorlist/' /etc/yum.repos.d/*.repo
                fi
                yum clean -q all
            fi

            ORIG=$(md5sum /etc/yum/pluginconf.d/fastestmirror.conf | cut -f 1 -d ' ')
            TEST=$(md5sum /vagrant/install/files/fastestmirror.conf | cut -f 1 -d ' ')
            if [[ "$ORIG" != "$TEST" ]]; then
                cp /vagrant/install/files/fastestmirror.conf /etc/yum/pluginconf.d/fastestmirror.conf
                yum clean -q all
            fi

            #bash /vagrant/install/ssh-init.sh
            #bash /vagrant/install/git-config.sh
            CONTENTS
            node.vm.provision "config", type: "shell" do |s|
                s.inline = $config
            end

            node.vm.provision "system", type: "ansibleLocal" do |a|
                a.playbook       = "install/systems/system.#{cfg[:distro]}.#{cfg[:web]}.yml"
                a.verbose        = false
                a.guest_folder   = "/vagrant/install"
                a.limit          = "#{cfg[:name]}"
                a.extra_vars     = {
                    "url"    => cfg[:hostname],
                }
            end

            # Product install, setup etc.
            $install = <<-CONTENTS
                bash /vagrant/install/install.sh #{cfg[:distro]} "#{cfg[:web]}"
            CONTENTS
            node.vm.provision "install", type: "shell", inline: $install
        end
    end
end
