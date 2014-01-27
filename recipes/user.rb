#
# Cookbook Name:: fdb
# Recipe:: user
#

group "foundationdb" do
  system true
end

user "foundationdb" do
  system true
  group "foundationdb"
  home "/var/lib/foundationdb"
  comment "FoundationDB"
  shell "/bin/false"
end
