#
# Cookbook Name:: pio
# Recipe:: hadoop
#
# Copyright 2016 ActionML LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0


include_recipe 'pio::user'

hadoop = node['pio']['hadoop']

user 'hadoop' do
  home  "#{node['pio']['prefix_home']}/hadoop"
  shell '/bin/false'
  system true
  manage_home false

  action :create
end

## Install hadoop from source
#
ark 'hadoop' do
  version hadoop['version']
  checksum hadoop['sha256']
  url hadoop['url']
end

## Create hadoop file-system directories
#
dirs = %w(tmp dfs dfs/name dfs/sname dfs/data1)
dirs.map {|dir| File.join(node['pio']['libdir'], 'hadoop', dir) }.each do |path|

  directory path do
    owner 'hadoop'
    group 'hadoop'
    mode '0750'
    recursive true
    action :create
  end

end

# Generate hadoop core-site config
template 'core-site.xml' do
  source 'core-site.xml.erb'
  path File.join(node['pio']['prefix_home'], 'hadoop/etc/hadoop/core-site.xml')
  mode '0644'

  notifies :restart, 'service_manager[hdfs-namenode]'
  notifies :restart, 'service_manager[hdfs-datanode]'
  action :create
end

# Generate hadoop hdfs-site config
template 'hdfs-site.xml' do
  source 'aio-hdfs-site.xml.erb'
  path File.join(node['pio']['prefix_home'], 'hadoop/etc/hadoop/hdfs-site.xml')
  mode '0644'

  notifies :restart, 'service_manager[hdfs-namenode]'
  notifies :restart, 'service_manager[hdfs-datanode]'
  action :create
end

## Start hadoop services
#

# First format HDFS if it's not formatted
bash 'format hdfs' do
  user 'hadoop'
  group 'hadoop'

  code "#{node['pio']['prefix_home']}/hadoop/bin/hdfs namenode -format"
  creates "#{node['pio']['libdir']}/hadoop/dfs/name/current/VERSION"
end

service_manager 'hdfs-namenode' do
  supports status: true, reload: false
  user 'hadoop'
  group 'hadoop'

  exec_command "#{node['pio']['prefix_home']}/hadoop/bin/hdfs namenode"
  exec_procregex 'org.apache.hadoop.hdfs.server.namenode.NameNode'

  variables(home_prefix: node['pio']['prefix_home'])

  manager node['pio']['service_manager']
  action :start
end

service_manager 'hdfs-datanode' do
  supports status: true, reload: false
  user 'hadoop'
  group 'hadoop'

  exec_command "#{node['pio']['prefix_home']}/hadoop/bin/hdfs datanode"
  exec_procregex "org.apache.hadoop.hdfs.server.datanode.DataNode"

  variables(home_prefix: node['pio']['prefix_home'])

  manager node['pio']['service_manager']
  action :start
end

service_manager 'hadoop' do
  supports status: true, reload: false
  exec_command :noop

  manager node['pio']['service_manager']
  action :start
end
