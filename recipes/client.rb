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

  if cluster_id = node['fdb']['cluster']
    coordinators = []
    search(:node, "fdb_cluster:#{cluster_id}") do |cnode|
      (cnode['fdb']['server'] or []).each do |serv|
        coordinators << "#{cnode['ipaddress']}:#{serv['id']}" if serv['coordinator']
      end
    end
    coordinators.sort!

    if File.exists?('/etc/foundationdb/fdb.cluster') &&
       (node['fdb']['server'] || []).detect {|s| s['coordinator'] }
      # Change an existing cluster via command line.
      old_cluster = IO.read('/etc/foundationdb/fdb.cluster')
      old_coordinators = old_cluster =~ /.+@(.*)/ && $1.split(',')
      unless coordinators == old_coordinators
        command = "coordinators #{coordinators.join(' ')}"
        fdb command do
          
        end
      end
    else
      # Just update file.
      file "/etc/foundationdb/fdb.cluster" do
        content "local:#{cluster_id}@#{coordinators.join(',')}"
        mode "0644"
      end
    end
  end

end
