######
# Base cookbook attributes
#
default['pio']['provision_only'] = false
default['pio']['ulimit_nofile']  = 64_000

default['pio']['localdir']    = '/usr/local'
default['pio']['datadir']     = '/opt/data'
default['pio']['datasubdirs'] = []

default['pio']['service_manager'] = nil

default['pio']['apache_mirror'] = 'http://apache.mirrors.tds.net'

# PIO system user and home (the former can be omitted)
default['pio']['user'] = 'aml'
default['pio']['home'] = ''

######
# PIO git repository and revision
#
default['pio']['giturl'] = 'https://github.com/apache/incubator-predictionio.git'
default['pio']['gitrev'] = 'v0.12.0-incubating'
default['pio']['gitupdate'] = true

# pio pip package
default['pio']['pip_package_version'] = '0.9.8'

######
# Universal recommender defaults
#
default['pio']['ur']['giturl'] = 'https://github.com/actionml/universal-recommender.git'
default['pio']['ur']['gitrev'] = '0.7.0'
default['pio']['ur']['gitupdate'] = true

## Mahout defaults
#
default['pio']['mahout']['giturl'] = 'https://github.com/actionml/mahout.git'
default['pio']['mahout']['gitrev'] = 'sparse-speedup-13.0'
default['pio']['mahout']['gitupdate'] = true

################
# Scala defaults
#
default['pio']['scala']['version'] = '2.11.11'

## PIO configuration defaults
#
default['pio']['conf']['event_port'] = 7070
default['pio']['conf']['prediction_port'] = 8000

default['pio']['conf']['es_clustername'] = 'elasticsearch'
default['pio']['conf']['es_hosts'] = %w[127.0.0.1]
## es_ports can be a list of ports corresponding hosts,
#  if default default port 9300 is used, this list can be omitted.
# default['pio']['conf']['es_ports'] = %w()

default['pio']['conf']['namenode_host'] = '127.0.0.1'
default['pio']['conf']['namenode_port'] = 9000
default['pio']['conf']['zookeeper_hosts'] = %w[127.0.0.1]
default['pio']['conf']['zookeeper_port'] = 2181

########################
# HDFS initial structure
#
# path(directory) user mode group
#
default['pio']['hdfs_structure'] = [
  ['/hbase', 'hadoop', '0755'],
  ['/user'],
  ["/user/#{node['pio']['user']}", node['pio']['user'], '0755'],
  ['/models', node['pio']['user'], '0755']
]
