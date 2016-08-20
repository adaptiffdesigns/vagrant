# -*- mode: ruby -*-
# # vi: set ft=ruby :
PRODUCTS = {
    :centos => {
        :arch     => "x86_64",
        :box      => "IngussNeilands/centos7-blank",
        :ip       => "192.168.50.4",
        :hostname => "centos.nginx.phalconvagrant.com", # Fill in desired hostname
        :web      => "nginx",
        :name     => "nginx",
        :distro   => "centos7",
        :boxname  => "phalcon_centos_7_nginx",
    },
}
<<-DOC
    :ubuntuapache => {
        :arch     => "x86_64",
        :box      => "ubuntu/trusty64",
        :ip       => "192.168.50.2",
        :hostname => "apache.phalconvagrant.com", # Fill in desired hostname
        :web      => "apache",
        :name     => "apache",
        :distro   => "ubuntu",
        :boxname  => "phalcon_centos_7_nginx",
    },
    :ubuntunginx => {
        :arch     => "x86_64",
        :box      => "ubuntu/trusty64",
        :ip       => "192.168.50.3",
        :hostname => "nginx.phalconvagrant.com", # Fill in desired hostname
        :web      => "nginx",
        :name     => "nginx",
        :distro   => "ubuntu",
        :boxname  => "phalcon_centos_7_nginx",
    },
    DOC