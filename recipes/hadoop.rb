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


## Bootstrap HDFS PIO default directory structure
#
if not File.exist?("#{node['pio']['libdir']}/hadoop/dfs/data1/.bootstrapped")
  node['pio']['hdfs']['bootstrap'].each do |path, user, mode, group|

    # defaults hdfs directory settings
    user  ||= node['pio']['hdfs']['user']
    group ||= node['pio']['hdfs']['group']
    mode  ||= '0755'

    execute "hdfs mkdir: #{path}" do
      cwd File.join(node['pio']['home_prefix'], 'hadoop/bin')
      user node['pio']['hdfs']['user']

      command "./hdfs dfs -mkdir -p #{path}"
      action :run
    end

    execute "hdfs chown: #{path}" do
      cwd File.join(node['pio']['home_prefix'], 'hadoop/bin')
      user node['pio']['hdfs']['user']

      command "./hdfs dfs -chown #{user}:#{group} #{path}"
      action :run
    end

    execute "hdfs chmod: #{path}" do
      cwd File.join(node['pio']['home_prefix'], 'hadoop/bin')
      user node['pio']['hdfs']['user']

      command "./hdfs dfs -chmod #{mode} #{path}"
      action :run
    end
  end

  execute 'touch .bootstrapped' do
    user node['pio']['hdfs']['user']
    command "touch #{node['pio']['libdir']}/hadoop/dfs/data1/.bootstrapped"
  end
end
