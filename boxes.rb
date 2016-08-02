# -*- mode: ruby -*-
# # vi: set ft=ruby :
PRODUCTS = {
    :ubuntu-a => {
        :arch     => "x86_64",
        :box      => "ubuntu/trusty64",
        :ip       => "192.168.50.2",
        :hostname => "apache.phalconvagrant.com", # Fill in desired hostname
        :web      => "apache",
        :name     => "apache",
        :distro   => "ubuntu",
    },
    :ubuntu-n => {
        :arch     => "x86_64",
        :box      => "ubuntu/trusty64",
        :ip       => "192.168.50.3",
        :hostname => "nginx.phalconvagrant.com", # Fill in desired hostname
        :web      => "nginx",
        :name     => "nginx",
        :distro   => "ubuntu",
    },
    :centos => {
        :arch     => "x86_64",
        :box      => "centos/7",
        :ip       => "192.168.50.4",
        :hostname => "centos.nginx.phalconvagrant.com", # Fill in desired hostname
        :web      => "nginx",
        :name     => "nginx",
        :distro   => "centos7",
    },
}