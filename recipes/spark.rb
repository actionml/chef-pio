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
include_recipe 'pio::spark_install'

## Start Spark services
#

service_manager 'spark-master' do
  manager node['pio']['service_manager']
  supports status: true, reload: false
  user 'aml'
  group 'hadoop'

  exec_env(
    SPARK_HOME: "#{node['pio']['home_prefix']}/spark"
  )
  exec_command "#{node['pio']['home_prefix']}/spark/sbin/start-spark.sh master"
  exec_procregex 'org.apache.spark.deploy.master.Master'

  variables(
    home_prefix: node['pio']['home_prefix'],
    nofile: node['pio']['spark']['nofile']
  )

  subscribes :restart, 'template[spark-env.sh]'
  subscribes :restart, 'template[spark-defaults.conf]'

  provision_only node['pio']['provision_only']
  action :start
end

service_manager 'spark-worker' do
  manager node['pio']['service_manager']
  supports status: true, reload: false
  user 'aml'
  group 'hadoop'

  exec_env(
    SPARK_HOME: "#{node['pio']['home_prefix']}/spark"
  )
  exec_command "#{node['pio']['home_prefix']}/spark/sbin/start-spark.sh worker"
  exec_procregex 'org.apache.spark.deploy.worker.Worker'

  variables(
    home_prefix: node['pio']['home_prefix'],
    nofile: node['pio']['spark']['nofile']
  )

  subscribes :restart, 'template[spark-env.sh]'
  subscribes :restart, 'template[spark-defaults.conf]'

  provision_only node['pio']['provision_only']
  action :start
end

service_manager 'spark' do
  manager node['pio']['service_manager']
  supports status: true, reload: false
  exec_command :noop

  provision_only node['pio']['provision_only']
  action :start
end
