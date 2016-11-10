#
# Cookbook Name:: pio
# Recipe:: spark
#
# Copyright 2016 ActionML LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0


include_recipe 'pio::base'

spark = node['pio']['spark']

## Install spark from source
#
ark 'spark' do
  version spark['version']
  checksum spark['sha256']
  url spark['url']
end

# start wrapper
cookbook_file 'start-spark.sh' do
  path "#{node['pio']['home_prefix']}/spark/sbin/start-spark.sh"
  owner 'root'
  group 'root'
  mode '0755'
end

## Create spark directory
#

## Create spark file-system directories
#
dirs = %w(. logs work)
dirs.map {|dir| File.join(node['pio']['libdir'], 'spark', dir) }.each do |path|
  directory path do
    owner 'aml'
    group 'hadoop'
    mode '0750'
    recursive true
    action :create
  end
end

# Generate spark-env config
template 'spark-env.sh' do
  source 'spark-env.sh.erb'
  path File.join(node['pio']['home_prefix'], 'spark/conf/spark-env.sh')
  mode '0644'

  notifies :restart, 'service_manager[spark-master]'
  notifies :restart, 'service_manager[spark-worker]'
  action :create
end

# Generate spark-defaults config
template 'spark-defaults.conf' do
  source 'spark-defaults.conf.erb'
  path File.join(node['pio']['home_prefix'], 'spark/conf/spark-defaults.conf')
  mode '0644'

  notifies :restart, 'service_manager[spark-master]'
  notifies :restart, 'service_manager[spark-worker]'
  action :create
end


## Start Spark services
#
service_manager 'spark-master' do
  supports status: true, reload: false
  user 'aml'
  group 'hadoop'

  exec_command "#{node['pio']['home_prefix']}/spark/sbin/start-spark.sh master"
  exec_procregex 'org.apache.spark.deploy.master.Master'

  variables(home_prefix: node['pio']['home_prefix'])

  manager node['pio']['service_manager']
  action :start
end

service_manager 'spark-worker' do
  supports status: true, reload: false
  user 'aml'
  group 'hadoop'

  exec_command "#{node['pio']['home_prefix']}/spark/sbin/start-spark.sh worker"
  exec_procregex 'org.apache.spark.deploy.worker.Worker'

  variables(home_prefix: node['pio']['home_prefix'])

  manager node['pio']['service_manager']
  action :start
end

service_manager 'spark' do
  supports status: true, reload: false
  exec_command :noop

  manager node['pio']['service_manager']
  action :start
end
