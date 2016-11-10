#
# Cookbook Name:: pio
# Recipe:: hbase
#
# Copyright 2016 ActionML LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0


include_recipe 'pio::base'

hbase = node['pio']['hbase']

## Install hbase from source
#
ark 'hbase' do
  version hbase['version']
  checksum hbase['sha256']
  url hbase['url']
end

## Create hbase directory
#

## Create hbase file-system directories
#

dirs = %w(. logs)
dirs.map {|dir| File.join(node['pio']['libdir'], 'hbase', dir) }.each do |path|
  directory path do
    owner 'hadoop'
    group 'hadoop'
    mode '0750'
    recursive true
    action :create
  end
end

# Generate hbase-default config
template 'hbase-env.sh' do
  source 'hbase-env.sh.erb'
  path File.join(node['pio']['home_prefix'], 'hbase/conf/hbase-env.sh')
  mode '0644'

  notifies :restart, 'service_manager[hbase-master]'
  action :create
end

# Generate hbase-site config
template 'hbase-site.xml' do
  source 'hbase-site.xml.erb'
  path File.join(node['pio']['home_prefix'], 'hbase/conf/hbase-site.xml')
  mode '0644'

  notifies :restart, 'service_manager[hbase-master]'
  action :create
end

## Start HBase services
#

service_manager 'hbase-master' do
  supports status: true, reload: false
  user 'hadoop'
  group 'hadoop'

  exec_command "#{node['pio']['home_prefix']}/hbase/bin/hbase master start"
  exec_procregex 'org.apache.hadoop.hbase.master.HMaster'

  variables(home_prefix: node['pio']['home_prefix'])

  manager node['pio']['service_manager']
  action :start
end

## RegionServer is not required in non-distributed mode!!!

## Wrapper service
service_manager 'hbase' do
  supports status: true, reload: false
  exec_command :noop

  manager node['pio']['service_manager']
  action :start
end
