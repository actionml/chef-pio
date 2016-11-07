
## Hadoop
#
default['pio']['hadoop']['version'] = '2.7.2'
default['pio']['hadoop']['sha256'] = '49ad740f85d27fa39e744eb9e3b1d9442ae63d62720f0aabdae7aa9a718b03f7'
default['pio']['hadoop']['basename'] = "hadoop-#{node['pio']['hadoop']['version']}"
default['pio']['hadoop']['archive'] = "#{node['pio']['hadoop']['basename']}.tar.gz"

default['pio']['hadoop']['url'] = "#{
  File.join(node['pio']['apache_mirror'],
            'hadoop/common',
            node['pio']['hadoop']['basename'],
            node['pio']['hadoop']['archive']

  )
}"


## HBase
#
default['pio']['hbase']['version'] = '1.2.4'
default['pio']['hbase']['sha256'] = '012d506796e28537cdf6e7cf512dc3b6b3c562e2863ca0ec5d48722bffdd265e'
default['pio']['hbase']['basename'] = "hbase-#{node['pio']['hbase']['version']}"
default['pio']['hbase']['archive'] = "#{node['pio']['hbase']['basename']}-bin.tar.gz"

default['pio']['hbase']['url'] = "#{
  File.join(node['pio']['apache_mirror'], 'hbase',
            node['pio']['hbase']['version'],
            node['pio']['hbase']['archive']
  )
}"


## Spark
#
default['pio']['spark']['version'] = '1.6.3'
default['pio']['spark']['sha256'] = '389e79458ad1d8ad8044643d97304d09bf3ca31f804c386e560033c48123cd69'
default['pio']['spark']['basename'] = "spark-#{node['pio']['spark']['version']}"
default['pio']['spark']['archive'] = "#{node['pio']['spark']['basename']}-bin-hadoop2.6.tgz"

default['pio']['spark']['url'] = "#{
  File.join(node['pio']['apache_mirror'], 'spark',
            node['pio']['spark']['basename'],
            node['pio']['spark']['archive']
  )
}"


## ElasticSearch
#
default['elasticsearch']['version'] = '1.7.5'
