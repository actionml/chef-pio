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
