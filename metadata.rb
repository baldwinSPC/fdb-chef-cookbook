name             'fdb'
maintainer       'FoundationDB'
maintainer_email 'distribution@foundationdb.com'
license          'MIT'
description      'Installs/Configures fdb'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.1'

%w{ debian ubuntu centos redhat }.each do |os|
  supports os
end

depends           "apt"
depends           "java"

attribute "fdb/cluster",
  :display_name => "FDB Cluster definition",
  :description => "fdb.cluster contents"
