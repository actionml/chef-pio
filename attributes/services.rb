
## Hadoop
#
default['pio']['hadoop']['version'] = '2.7.3'
default['pio']['hadoop']['sha256'] = 'd489df3808244b906eb38f4d081ba49e50c4603db03efd5e594a1e98b09259c2'
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
default['pio']['hbase']['version'] = '1.2.6'
default['pio']['hbase']['sha256'] = 'a0fbc22373a7f2d66648c6d9fe13477e689df50c8ee533eda962d4e8fa2185ea'
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
