
## Hadoop
#
default['pio']['hadoop']['version'] = '2.7.2'
default['pio']['hadoop']['sha256'] = '49ad740f85d27fa39e744eb9e3b1d9442ae63d62720f0aabdae7aa9a718b03f7'
default['pio']['hadoop']['basename'] = "hadoop-#{node['pio']['hadoop']['version']}"
default['pio']['hadoop']['archive'] = "#{node['pio']['hadoop']['basename']}.tar.gz"
default['pio']['hadoop']['nofile'] = "#{node['pio']['ulimit_nofile']}"

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
default['pio']['hbase']['nofile'] = "#{node['pio']['ulimit_nofile']}"

default['pio']['hbase']['url'] = "#{
  File.join(node['pio']['apache_mirror'], 'hbase',
            node['pio']['hbase']['version'],
            node['pio']['hbase']['archive']
  )
}"


## Spark
#
default['pio']['spark']['version'] = '1.6.3'
default['pio']['spark']['sha256'] = 'd13358a2d45e78d7c8cf22656d63e5715a5900fab33b3340df9e11ce3747e314'
default['pio']['spark']['basename'] = "spark-#{node['pio']['spark']['version']}"
default['pio']['spark']['archive'] = "#{node['pio']['spark']['basename']}-bin-without-hadoop.tgz"
default['pio']['spark']['nofile'] = "#{node['pio']['ulimit_nofile']}"

default['pio']['spark']['url'] = "#{
  File.join(node['pio']['apache_mirror'], 'spark',
            node['pio']['spark']['basename'],
            node['pio']['spark']['archive']
  )
}"


## ElasticSearch
#
default['elasticsearch']['version'] = '1.7.5'
