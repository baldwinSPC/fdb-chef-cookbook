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

if node['fdb']['cluster']
  directory "/etc/foundationdb" do
  end

  file "/etc/foundationdb/fdb.cluster" do
    content "#{node['fdb']['cluster']}"
    mode "0644"
    action :create_if_missing
  end
end
