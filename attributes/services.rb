########
# Hadoop
#
default['pio']['hadoop']['version']  = '2.8.3'
default['pio']['hadoop']['sha256']   = 'e8bf9a53337b1dca3b152b0a5b5e277dc734e76520543e525c301a050bb27eae'
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
default['pio']['hbase']['version']  = '1.4.1'
default['pio']['hbase']['sha256']   = '4b56f7c7c45eab47090b65e6d401212e1b41eacedae2732dff0231325432171a'
default['pio']['hbase']['basename'] = "hbase-#{node['pio']['hbase']['version']}"
default['pio']['hbase']['archive']  = "#{node['pio']['hbase']['basename']}-bin.tar.gz"
default['pio']['hbase']['nofile']   = node['pio']['ulimit_nofile'].to_s

default['pio']['hbase']['url'] =
  File.join(node['pio']['apache_mirror'], 'hbase',
            node['pio']['hbase']['version'],
            node['pio']['hbase']['archive']).to_s

#######
# Spark
#
default['pio']['spark']['version']  = '2.1.2'
default['pio']['spark']['sha256']   = '108d924b5e979e41b4e72dcc8bb1a185769378900d0215f9dd926eebd1ea7e39'
default['pio']['spark']['basename'] = "spark-#{node['pio']['spark']['version']}"
default['pio']['spark']['archive']  = "#{node['pio']['spark']['basename']}-bin-without-hadoop.tgz"
default['pio']['spark']['nofile']   = node['pio']['ulimit_nofile'].to_s

default['pio']['spark']['url'] =
  File.join(node['pio']['apache_mirror'], 'spark',
            node['pio']['spark']['basename'],
            node['pio']['spark']['archive']).to_s

###############
# ElasticSearch
# Version is applied by the upstream cookbook, we use ES 5.X
