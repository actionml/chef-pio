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
default['pio']['hbase']['version']  = '1.4.6'
default['pio']['hbase']['checksum'] = '4b3769f7d2d829dc212b9ace36d83dd17d3e4f674d0cf39a7cdee1ae47e23d37'
default['pio']['hbase']['archive']  = "hbase-#{node['pio']['hbase']['version']}-bin.tar.gz"
default['pio']['hbase']['nofile']   = node['pio']['ulimit_nofile'].to_s

default['pio']['hbase']['url'] =
  File.join(node['pio']['apache_mirror'], 'hbase',
            node['pio']['hbase']['version'],
            node['pio']['hbase']['archive']).to_s

#######
# Spark
#
default['pio']['spark']['version']  = '2.1.3'
default['pio']['spark']['checksum'] = 'b489655c777c94e25425ce63f54046118f924e00e1630237a4b86018a098ab91'
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
