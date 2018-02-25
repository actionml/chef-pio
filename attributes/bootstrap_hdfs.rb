default['pio']['hdfs']['user']  = 'hadoop'
default['pio']['hdfs']['group'] = 'hadoop'
default['pio']['hdfs']['bootstrap'] = [
  # path(directory) user mode group
  ['/hbase', 'hadoop', '0755'],
  ['/user'],
  ["/user/#{node['pio']['user']}", node['pio']['user'], '0755'],
  ['/models', node['pio']['user'], '0755']
]
