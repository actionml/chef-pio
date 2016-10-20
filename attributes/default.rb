default['pio']['bundle'] = 'aml'
default['pio']['install_method'] = 'git'

default['pio']['databasedir'] = '/opt/data'
default['pio']['homedir'] = '/usr/local/pio'
default['pio']['datadir'] = "#{File.join(node['pio']['databasedir'], 'pio')}"
default['pio']['user'] = 'aml'

default['pio']['eventserver']['port'] = 31729
default['pio']['predictionserver']['port'] = 31730

default['pio']['aml']['giturl'] = 'https://github.com/actionml/PredictionIO.git'
default['pio']['aml']['gitrev'] = 'master'
default['pio']['aml']['gitupdate'] = true

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
