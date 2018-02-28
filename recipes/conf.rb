#
# Cookbook Name:: pio
# Recipe:: conf
#
# Copyright 2016 ActionML LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0

# Create pio config directories for  services: hadoop and hbase
%w[hadoop hbase].each do |dir|
  directory File.join('/usr/local/pio', 'conf', dir)
end

# generate pio-env.sh
template 'pio-env.sh' do
  path   File.join('/usr/local/pio', 'conf', 'pio-env.sh')
  source 'pio-env.sh.erb'
  mode   0_644

  variables(lazy do
    {
      spark_home: node['pio']['conf']['spark_home'],
      es_clustername: node['pio']['conf']['es_clustername'],
      es_hosts: Array(node['pio']['conf']['es_hosts']),
      es_ports: Array(node['pio']['conf']['es_ports'])
    }
  end)

  action :create
end

# generate hadoop/hbase config files for pio
%w[hadoop/core-site.xml hbase/hbase-site.xml].each do |path|
  template File.join('/usr/local/pio', 'conf', path) do
    source "#{File.basename(path)}.erb"
    mode '0644'
  end
end
