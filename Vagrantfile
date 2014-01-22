# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|

  cluster_size = ENV['FDB_CLUSTER_SIZE']
  cluster_file = ENV['FDB_CLUSTER']
  if cluster_size.nil?
    if cluster_file.nil?
      cluster_size = 2          # External server
    else
      cluster_size = 0          # No servers
    end
  end
  if cluster_file.nil?
    cluster_file = "fdb.cluster"
    unless File.exists?(cluster_file)
      chars = [('0'..'9'), ('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
      cluster_id = (1..8).map { chars[rand(chars.length)] }.join
      IO.write cluster_file, "local:#{cluster_id}@10.33.33.30:4500"
    end
  end
  cluster_fdb_attrs = { 'cluster' => IO.read(cluster_file) }

  if Vagrant.has_plugin?('vagrant-cachier')
    config.cache.auto_detect = true
    config.cache.enable :chef
    config.cache.enable :apt
  end

  config.vm.box = 'ubuntu'
  config.vm.box_url = 'http://files.vagrantup.com/precise64.box'
  
  config.berkshelf.enabled = true

  cluster_size.times do |n|

    config.vm.define "fdb-#{n}" do |fdb_config|
      
      fdb_config.vm.hostname = "fdb-#{n}"

      fdb_config.vm.provider :virtualbox do |vb|
        vb.customize ['modifyvm', :id, '--memory', '1024']
      end

      fdb_config.vm.network :private_network, :ip => "10.33.33.#{30 + n}"

      node_fdb_attrs = cluster_fdb_attrs.dup
      node_fdb_attrs['coordinator'] = '1' if n == 0

      fdb_config.vm.provision :chef_solo do |chef|
        chef.json = { 'fdb' => node_fdb_attrs }

        chef.run_list = [ 'recipe[fdb::server]' ]
      end

    end

  end

  config.vm.define 'sql-layer' do |sql_config|
  
    sql_config.vm.hostname = 'sql-layer'

    sql_config.vm.provider :virtualbox do |vb|
      vb.customize ['modifyvm', :id, '--memory', '512', '--cpus', '2']
    end

    sql_config.vm.network :private_network, :ip => '10.33.33.50'

    node_fdb_attrs = cluster_fdb_attrs.dup
    sql_config.vm.provision :chef_solo do |chef|
      chef.json = { 'fdb' => node_fdb_attrs }

      chef.run_list = [ 'recipe[fdb::sql_layer]' ]
    end

  end
  
end
