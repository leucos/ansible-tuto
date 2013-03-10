# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.define :host1 do |web_config|
    web_config.vm.box = "precise32"
    web_config.vm.box_url = "http://files.vagrantup.com/precise32.box"
    web_config.vm.customize ["modifyvm", :id, "--memory", 200]
    web_config.vm.host_name = "host1.example.org"
    web_config.vm.network :hostonly, "192.168.33.11"
  end

 config.vm.define :host2 do |web_config|
    web_config.vm.box = "precise32"
    web_config.vm.box_url = "http://files.vagrantup.com/precise32.box"
    web_config.vm.customize ["modifyvm", :id, "--memory", 200]
    web_config.vm.host_name = "host2.example.org"
    web_config.vm.network :hostonly, "192.168.33.12"
 end

 config.vm.define :host0 do |ha_config|
    ha_config.vm.box = "precise32"
    ha_config.vm.box_url = "http://files.vagrantup.com/precise32.box"
    ha_config.vm.customize ["modifyvm", :id, "--memory", 200]
    ha_config.vm.host_name = "host0.example.org"
    ha_config.vm.network :hostonly, "192.168.33.10"
  end
end

