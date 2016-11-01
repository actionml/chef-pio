## Base files, directories and install method
#
default['pio']['bundle'] = 'aml'
default['pio']['install_method'] = 'git'

default['pio']['prefix_home'] = '/usr/local'
default['pio']['libdir'] = '/opt/data'
default['pio']['rootdir'] = "#{File.join(node['pio']['libdir'], 'pio')}"
default['pio']['user_homedir'] = "#{File.join(node['pio']['rootdir'], 'home')}"
default['pio']['user'] = 'aml'
default['pio']['apache_mirror'] = node['ark']['apache_mirror']

default['pio']['service_manager'] = 'auto'

## AML install method (bundle aml)
#
default['pio']['aml']['giturl'] = 'https://github.com/actionml/PredictionIO.git'
default['pio']['aml']['gitrev'] = 'master'
default['pio']['aml']['gitupdate'] = true


## PIO configuration defaults
#
default['pio']['conf']['event_port'] = 31729
default['pio']['conf']['prediction_port'] = 31730

default['pio']['conf']['spark_home'] = '/usr/local/spark'
default['pio']['conf']['es_clustername'] = 'elasticsearch'
default['pio']['conf']['es_hosts'] = %w(127.0.0.1)
## es_ports can be a list of ports corresponding hosts,
#  if default default port 9300 is used, this list can be omitted.
# default['pio']['conf']['es_ports'] = %w()

default['pio']['conf']['namenode_host'] = '127.0.0.1'
default['pio']['conf']['namenode_port'] = 9000
default['pio']['conf']['zookeeper_hosts'] = %w(127.0.0.1)
default['pio']['conf']['zookeeper_port'] = 2181
