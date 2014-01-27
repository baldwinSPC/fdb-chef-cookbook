#
# Cookbook Name:: fdb
# Recipe:: client
#

pkg_version = "1.0.1"
pkg_file = case node['platform_family']
           when 'debian' then "foundationdb-clients_#{pkg_version}-1_amd64.deb"
           when 'rhel', 'fedora' then "foundationdb-clients-#{pkg_version}-1.x86_64.rpm"
           # when 'mac_os_x' ...
           # when 'windows' ...
           else raise "Cannot handle this platform yet" end

remote_file "#{Chef::Config[:file_cache_path]}/#{pkg_file}" do
  source "https://foundationdb.com/downloads/I_accept_the_FoundationDB_Community_License_Agreement/#{pkg_version}/#{pkg_file}"
end

package "foundationdb-clients" do
  version "#{pkg_version}-1"
  source "#{Chef::Config[:file_cache_path]}/#{pkg_file}"
  provider Chef::Provider::Package::Dpkg if node['platform_family'] == 'debian'
end

if node.attribute?('fdb')
  directory "/etc/foundationdb" do
  end

  if cluster_name = node['fdb']['cluster']
    cluster_item = data_bag_item('fdb_cluster', cluster_name)
    prefix = "#{cluster_name.gsub(/[^a-zA-Z0-9_]/,'_')}:#{cluster_item['unique_id']}"

    coordinators = []
    search(:node, "fdb_cluster:#{cluster_name}") do |cnode|
      (cnode['fdb']['server'] or []).each do |serv|
        if serv['coordinator']
          addr = "#{cnode['ipaddress']}:#{serv['id']}" 
          addr += ":tls" if cluster_item['tls']
          coordinators << addr
        end
      end
    end
    coordinators.sort!

    update_file = true
    if File.exists?('/etc/foundationdb/fdb.cluster') &&
       (node['fdb']['server'] || []).detect {|s| s['coordinator'] }
      old_cluster = IO.read('/etc/foundationdb/fdb.cluster')
      if old_cluster =~ /(.+)@(.+)/ && prefix == $1
        old_coordinators = $2.split(',')
        # Change an existing cluster via command line.
        unless coordinators == old_coordinators
          command = "coordinators #{coordinators.join(' ')}"
          fdb command do
            
          end
        end
        update_file = false
      end
    end
    if update_file
      # Just update file.
      file "/etc/foundationdb/fdb.cluster" do
        content "#{prefix}@#{coordinators.join(',')}"
        mode "0644"
      end
    end
  end

end
