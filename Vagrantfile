Vagrant.configure "2" do |config|
  config.vm.box = "precise64"
  config.vm.network :private_network, ip: '192.168.85.10'
  config.vm.provision :shell, path: './bootstrap.sh'
end
