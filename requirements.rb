# -*- mode: ruby -*-
# # vi: set ft=ruby :
unless Vagrant.has_plugin?("vagrant-hostmanager")
    puts "Missing 'vagrant-hostmanager'."
    puts "Run `vagrant plugin install vagrant-hostmanager` and then try again."
    exit 1
end

unless Vagrant.has_plugin?("vagrant-ansible-local")
    puts "Missing 'vagrant-ansible-local'."
    puts "Run `vagrant plugin install vagrant-ansible-local` and then try again."
    exit 1
end

class KEYS
    def KEYS.public()
        if !ENV['PUB_KEY'].nil? and File.exists?(ENV['PUB_KEY'])
            return ENV['PUB_KEY']
        elsif File.exists?(File.join(Dir.home, '.ssh', 'id_rsa.pub'))
            return File.join(Dir.home, '.ssh', 'id_rsa.pub')
        elsif File.exists?(File.join(Dir.home, '.ssh', 'id_dsa.pub'))
            return File.join(Dir.home, '.ssh', 'id_dsa.pub')
        else
            return nil
        end
    end

    def KEYS.private()
        if !ENV['PRIV_KEY'].nil? and File.exists?(ENV['PRIV_KEY'])
            return ENV['PRIV_KEY']
        elsif File.exists?(File.join(Dir.home, '.ssh', 'id_rsa'))
            return File.join(Dir.home, '.ssh', 'id_rsa')
        elsif File.exists?(File.join(Dir.home, '.ssh', 'id_dsa'))
            return File.join(Dir.home, '.ssh', 'id_dsa')
        else
            return nil
        end
    end
end

class OS
    def OS.windows?
        (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
    end

    def OS.mac?
        (/darwin/ =~ RUBY_PLATFORM) != nil
    end

    def OS.unix?
        !OS.windows?
    end

    def OS.linux?
        OS.unix? and not OS.mac?
    end
end