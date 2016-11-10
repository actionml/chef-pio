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

include_recipe 'pio::hadoop_install'

# First format HDFS if it's not formatted
bash 'format hdfs' do
  user 'hadoop'
  group 'hadoop'

  code "#{node['pio']['home_prefix']}/hadoop/bin/hdfs namenode -format"
  creates "#{node['pio']['libdir']}/hadoop/dfs/name/current/VERSION"
end

service_manager 'hdfs-namenode' do
  supports status: true, reload: false
  user 'hadoop'
  group 'hadoop'

  exec_command "#{node['pio']['home_prefix']}/hadoop/bin/hdfs namenode"
  exec_procregex 'org.apache.hadoop.hdfs.server.namenode.NameNode'

  variables(home_prefix: node['pio']['home_prefix'])

  manager node['pio']['service_manager']

  subscribes :restart, 'template[core-site.xml]'
  subscribes :restart, 'template[hdfs-site.xml]'

  action :start
end

service_manager 'hdfs-datanode' do
  supports status: true, reload: false
  user 'hadoop'
  group 'hadoop'

  exec_command "#{node['pio']['home_prefix']}/hadoop/bin/hdfs datanode"
  exec_procregex "org.apache.hadoop.hdfs.server.datanode.DataNode"

  variables(home_prefix: node['pio']['home_prefix'])

  manager node['pio']['service_manager']

  subscribes :restart, 'template[core-site.xml]'
  subscribes :restart, 'template[hdfs-site.xml]'

  action :start
end

service_manager 'hadoop' do
  supports status: true, reload: false
  exec_command :noop

  manager node['pio']['service_manager']
  action :start
end
