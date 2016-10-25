
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
