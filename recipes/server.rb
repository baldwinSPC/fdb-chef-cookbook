#
# Cookbook Name:: fdb
# Recipe:: server
#

new_cluster = node['fdb']['coordinator'] == '1' && !::File.exists?('/etc/foundationdb/fdb.cluster')

include_recipe 'fdb::client'

pkg_version = "1.0.1"
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
#  subscribes :restart, 'template[/etc/foundationdb/fdb.cluster]'
end

if new_cluster
  fdb "configure new" do
    command "configure new single memory"
    timeout 20
  end
end

if node.attribute?('fdb')
  # TODO: generate foundationdb.conf with template.
end
