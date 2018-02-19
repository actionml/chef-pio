## Base files, directories and install method
#
default['pio']['aio'] = false
default['pio']['provision_only'] = false
default['pio']['bundle'] = 'aml'
default['pio']['pypi_pio_version'] = '0.9.8'
default['pio']['ulimit_nofile'] = 64000

default['pio']['home_prefix'] = '/usr/local'
default['pio']['libdir'] = '/opt/data'
default['pio']['apache_mirror'] = node['ark']['apache_mirror']

default['pio']['service_manager'] = 'auto'

## AML install method (bundle aml)
#
default['pio']['aml']['user'] = 'aml'

# conditional home
if node['pio']['aml']['user'] == 'root'
  default['pio']['aml']['home'] = '/root'
else
  default['pio']['aml']['home'] = "/home/#{node['pio']['aml']['user']}"
end

default['pio']['aml']['giturl'] = 'https://github.com/apache/incubator-predictionio.git'
default['pio']['aml']['gitrev'] = 'v0.12.0-incubating'
default['pio']['aml']['gitupdate'] = true

## Universal recommender defaults
#
default['pio']['ur']['giturl'] = 'https://github.com/actionml/universal-recommender.git'
default['pio']['ur']['gitrev'] = '0.7.0'
default['pio']['ur']['gitupdate'] = true

## Mahout defaults
#
default['pio']['mahout']['giturl'] = 'https://github.com/actionml/mahout.git'
default['pio']['mahout']['gitrev'] = 'ae984b8d3960bde18412da840fe5d9d8b75cdfcf'
default['pio']['mahout']['gitupdate'] = true

## PIO configuration defaults
#
default['pio']['conf']['event_port'] = 7070
default['pio']['conf']['prediction_port'] = 8000

default['pio']['conf']['es_clustername'] = 'elasticsearch'
default['pio']['conf']['es_hosts'] = %w(127.0.0.1)
## es_ports can be a list of ports corresponding hosts,
#  if default default port 9300 is used, this list can be omitted.
# default['pio']['conf']['es_ports'] = %w()

default['pio']['conf']['namenode_host'] = '127.0.0.1'
default['pio']['conf']['namenode_port'] = 9000
default['pio']['conf']['zookeeper_hosts'] = %w(127.0.0.1)
default['pio']['conf']['zookeeper_port'] = 2181
