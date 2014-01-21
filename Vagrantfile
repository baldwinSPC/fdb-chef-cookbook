# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|

  if ENV['FDB_CLUSTER']
    FDB_CLUSTER = IO.read(ENV['FDB_CLUSTER'])
  else
    puts "FATAL: Must specify cluster file in FDB_CLUSTER environment variable."
    exit
  end
  
  if Vagrant.has_plugin?('vagrant-cachier')
    config.cache.auto_detect = true
    config.cache.enable :chef
    config.cache.enable :apt
  end

  config.vm.box = 'ubuntu'
  config.vm.box_url = 'http://files.vagrantup.com/precise64.box'
  
  config.berkshelf.enabled = true

  config.vm.define 'sql-layer' do |sql_config|
  
    sql_config.vm.hostname = 'sql-layer'

    sql_config.vm.provider :virtualbox do |vb|
      vb.customize ['modifyvm', :id, '--memory', '512', '--cpus', '2']
    end

    sql_config.vm.network 'forwarded_port', guest: 15432, host: 49932

    sql_config.vm.provision :chef_solo do |chef|
      chef.json = {
        'fdb' => {
          'cluster' => "#{FDB_CLUSTER}"
        }
      }

      chef.run_list = [
        'recipe[fdb::sql_layer]'
      ]
    end

  end
  
end
