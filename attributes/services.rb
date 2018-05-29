########
# Hadoop
#
default['pio']['hadoop']['version']  = '2.8.4'
default['pio']['hadoop']['checksum'] = '6b545972fdd73173887cdbc3e1cbd3cc72068271924edea82a0e7e653199b115'
default['pio']['hadoop']['basename'] = "hadoop-#{node['pio']['hadoop']['version']}"
default['pio']['hadoop']['archive']  = "#{node['pio']['hadoop']['basename']}.tar.gz"
default['pio']['hadoop']['nofile']   = node['pio']['ulimit_nofile'].to_s

default['pio']['hadoop']['url'] =
  File.join(node['pio']['apache_mirror'], 'hadoop/common',
            node['pio']['hadoop']['basename'],
            node['pio']['hadoop']['archive']).to_s

#######
# HBase
#
default['pio']['hbase']['version']  = '1.4.4'
default['pio']['hbase']['checksum'] = '545521212660c877623e91b669acdcbaaf3aceeb283f989b6e4d17fd5c698bd1'
default['pio']['hbase']['archive']  = "hbase-#{node['pio']['hbase']['version']}-bin.tar.gz"
default['pio']['hbase']['nofile']   = node['pio']['ulimit_nofile'].to_s

default['pio']['hbase']['url'] =
  File.join(node['pio']['apache_mirror'], 'hbase',
            node['pio']['hbase']['version'],
            node['pio']['hbase']['archive']).to_s

#######
# Spark
#
default['pio']['spark']['version']  = '2.1.2'
default['pio']['spark']['checksum'] = '108d924b5e979e41b4e72dcc8bb1a185769378900d0215f9dd926eebd1ea7e39'
default['pio']['spark']['basename'] = "spark-#{node['pio']['spark']['version']}"
default['pio']['spark']['archive']  = "#{node['pio']['spark']['basename']}-bin-without-hadoop.tgz"
default['pio']['spark']['nofile']   = node['pio']['ulimit_nofile'].to_s

default['pio']['spark']['url'] =
  File.join(node['pio']['apache_mirror'], 'spark',
            node['pio']['spark']['basename'],
            node['pio']['spark']['archive']).to_s

###############
# ElasticSearch
# Version is pinned by the upstream cookbook, we use ES 5.X
