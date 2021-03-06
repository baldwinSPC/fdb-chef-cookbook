#
# Cookbook Name:: fdb
# Recipe:: server
#

new_cluster = node['fdb']['server'][0]['coordinator'] && !::File.exists?('/etc/foundationdb/fdb.cluster')

include_recipe 'fdb::user'
include_recipe 'fdb::client'

file "fdb.cluster owner" do
  path '/etc/foundationdb/fdb.cluster'
  owner 'foundationdb'
  group 'foundationdb'
end

pkg_version = "2.0.0"
pkg_file = case node['platform_family']
           when 'debian' then "foundationdb-server_#{pkg_version}-1_amd64.deb"
           when 'rhel', 'fedora' then "foundationdb-server-#{pkg_version}-1.x86_64.rpm"
           # when 'mac_os_x' ...
           # when 'windows' ...
           else raise "Cannot handle this platform yet" end

remote_file "#{Chef::Config[:file_cache_path]}/#{pkg_file}" do
  source "https://foundationdb.com/downloads/I_accept_the_FoundationDB_Community_License_Agreement/#{pkg_version}/#{pkg_file}"
end

package "foundationdb-server" do
  version "#{pkg_version}-1"
  source "#{Chef::Config[:file_cache_path]}/#{pkg_file}"
  provider Chef::Provider::Package::Dpkg if node['platform_family'] == 'debian'
end

service "foundationdb" do
  action :nothing
  supports :status => true, :restart => true
#  subscribes :restart, 'file[/etc/foundationdb/fdb.cluster]'
end

template "/etc/foundationdb/foundationdb.conf" do
  source "conf.erb"
  group "foundationdb"
  owner "foundationdb"
  mode "0644"
  variables({
    :servers => node['fdb']['server']
  })
  notifies :restart, 'service[foundationdb]', new_cluster ? :immediately : :delayed
end

if new_cluster
  cluster_item = data_bag_item('fdb_cluster', node['fdb']['cluster'])
  command = "configure new #{cluster_item['redundancy']} #{cluster_item['storage']}"
  fdb command do
    timeout 60
  end
end
