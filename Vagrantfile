# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'json'

Vagrant.configure('2') do |config|

  if Vagrant.has_plugin?('vagrant-cachier')
    config.cache.auto_detect = true
    config.cache.enable :chef
    config.cache.enable :apt
  end

  config.berkshelf.enabled = true

  # Script "arguments"
  server_count = (ENV['FDB_SERVER_COUNT'] || 2).to_i
  process_count = (ENV['FDB_PROCESS_COUNT'] || 1).to_i
  sql_layer_count = (ENV['FDB_SQL_LAYER_COUNT'] || 1).to_i
  cluster_name = ENV['FDB_CLUSTER_NAME'] || 'cluster-1'

  # Create everything where solo search can find it.
  Dir.mkdir 'data_bags' unless Dir.exists?('data_bags')
  Dir.mkdir 'data_bags/fdb_cluster' unless Dir.exists?('data_bags/fdb_cluster')
  
  cluster_file = "data_bags/fdb_cluster/#{cluster_name}.json"
  unless File.exists?(cluster_file)
    chars = [('0'..'9'), ('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    unique_id = (1..8).map { chars[rand(chars.length)] }.join
    IO.write cluster_file, JSON.dump({
      :id => cluster_name,
      :unique_id => unique_id,
      :redundancy => :single,
      :storage => :memory
    })
  end

  nodes = {}

  server_count.times do |n|
    node = {
      :id => "fdb-#{n}",
      :memory => 1024, :cpus => 1,
      :ipaddress => "10.33.33.#{30 + n}",
      :fdb => { 
        :cluster => cluster_name,
        :server => (4500..4500+process_count-1).collect {|id| { :id => id } }
      },
      :run_list => [ 'recipe[fdb::server]' ]
    }
    node[:fdb][:server][0][:coordinator] = true if n == 0
    nodes[node[:id]] = node
  end  

  sql_layer_count.times do |n|
    node = {
      :id => "sql-#{n}",
      :memory => 512, :cpus => 2,
      :ipaddress => "10.33.33.#{50 + n}",
      :fdb => { :cluster => cluster_name },
      :run_list => [ 'recipe[fdb::sql_layer]' ]
    }
    nodes[node[:id]] = node
  end

  Dir.mkdir 'data_bags/node' unless Dir.exists?('data_bags/node')
  nodes.each do |id, node|
    IO.write "data_bags/node/#{id}.json", JSON.dump(node)
  end

  config.vm.box = 'ubuntu'
  config.vm.box_url = 'http://files.vagrantup.com/precise64.box'
  
  nodes.each do |id, node|
    config.vm.define id do |vm_config|
      vm_config.vm.hostname = node[:id]

      vm_config.vm.provider :virtualbox do |vb|
        vb.customize ['modifyvm', :id, '--memory', node[:memory], '--cpus', node[:cpus] ]
      end

      vm_config.vm.network :private_network, :ip => node[:ipaddress]

      vm_config.vm.provision :chef_solo do |chef|
        chef.data_bags_path = 'data_bags'
        chef.json = node
        chef.run_list = node[:run_list]
      end
    end
  end
  
end
