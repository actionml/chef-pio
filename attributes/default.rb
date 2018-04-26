######
# Base cookbook attributes
#
default['pio']['provision_only'] = false
default['pio']['ulimit_nofile']  = 64_000

default['pio']['localdir']    = '/usr/local'
default['pio']['datadir']     = '/opt/data'
default['pio']['datasubdirs'] = ['big-data']

# Service manager uses the auto provider if not set or nil
# default['pio']['service_manager'] =

default['pio']['apache_mirror'] = 'http://apache.mirrors.tds.net'

# PIO system user and home (the former can be omitted)
default['pio']['user'] = 'aml'
# default['pio']['home'] =

###########################
# PredictionIO distribution
#
default['pio']['pio']['version']  = '0.12.1'
default['pio']['pio']['checksum'] = 'a939f1679c21d70eedab4cd30fe4f10cd5efec1128f7ada7f0bead3599d46676'
default['pio']['pio']['archive']  = "apache-predictionio-#{node['pio']['pio']['version']}-bin.tar.gz"
default['pio']['pio']['nofile']   = node['pio']['ulimit_nofile'].to_s
default['pio']['pio']['url'] =
  File.join(node['pio']['apache_mirror'], 'predictionio',
            node['pio']['pio']['version'],
            node['pio']['pio']['archive']).to_s

# pio pip package
default['pio']['pip_package_version'] = '0.9.8'

######
# Universal recommender defaults
#
default['pio']['ur']['giturl'] = 'https://github.com/actionml/universal-recommender.git'
default['pio']['ur']['gitrev'] = '0.7.1'
default['pio']['ur']['gitupdate'] = true

################
# Scala defaults
#
default['pio']['scala']['version'] = '2.11.11'

## PIO configuration defaults
#
default['pio']['conf']['eventserver_port'] = 7070
default['pio']['conf']['predictionserver_port'] = 8000

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
