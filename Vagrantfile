require 'json'

facts = JSON.parse(File.read('box.json'))

Vagrant.configure("2") do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  config.vm.hostname = facts["hostname"]

  config.vm.network :private_network, ip: facts["guest_ip"]
    config.vm.network :forwarded_port, guest: 22, host: 2225 
    config.vm.network :forwarded_port, guest: 80, host: 8085 
    config.ssh.forward_agent = true

  config.vm.provision :shell, :inline => "sudo apt-get update"

  config.vm.provider :virtualbox do |v|
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--memory", 2048]
    v.customize ["modifyvm", :id, "--name", facts["name"]]
  end
 
  config.vm.synced_folder ".", "/vagrant", id: "vagrant-root" 

  facterContent = ""
  facts.each { |key, value| facterContent += "#{key} = #{value}\n" }
  config.vm.provision :shell, :inline => 'echo -e "'+ facterContent +'" > /etc/vagrant.facts;'

  config.vm.provision :shell, :inline => "sudo apt-get update && sudo apt-get install puppet -y"
  
  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "manifests"
    puppet.module_path = "modules"
    puppet.options = ['--verbose']
  end
end