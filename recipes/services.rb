#
# Cookbook Name:: pio
# Recipe:: services
#
# Copyright 2018 ActionML LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0

include_recipe 'pio::default'

#
# This recipe brings up PIO dependent services. All Apache services
# are configured in Pseudo Distributed mode. This approach helps the user
# to interact with PIO so as it's a real distributed setup.
#

#################
# Hadoop services
#################

# Format HDFS
bash 'format hdfs' do
  user 'hadoop'
  group 'hadoop'

  code "#{default_variables[:hadoopdir]}/bin/hdfs namenode -format"
  creates "#{default_variables[:datadir]}/hadoop/dfs/name/current/VERSION"
end

# Hadoop namenode
service_manager 'hdfs-namenode' do
  supports status: true, reload: false
  user  'hadoop'
  group 'hadoop'

  # set vars before, since we use it in interpolation
  variables apache_vars(
    app: 'hadoop'
  )

  exec_command "#{variables[:appdir]}/bin/hdfs namenode"
  exec_procregex 'org.apache.hadoop.hdfs.server.namenode.NameNode'
  exec_env(
    'JAVA_HOME' => variables[:java_home]
  )

  subscribes :restart, 'apache_app[hadoop]' unless provision_only?

  manager node['pio']['service_manager']
  action service_actions
end

# Hadoop datanode
service_manager 'hdfs-datanode' do
  supports status: true, reload: false
  user  'hadoop'
  group 'hadoop'

  # set vars before, since we use it in interpolation
  variables apache_vars(
    app: 'hadoop'
  )

  exec_command "#{variables[:appdir]}/bin/hdfs datanode"
  exec_procregex 'org.apache.hadoop.hdfs.server.datanode.DataNode'
  exec_env(
    'JAVA_HOME' => variables[:java_home]
  )

  subscribes :restart, 'apache_app[hadoop]' unless provision_only?

  manager node['pio']['service_manager']
  action service_actions
end

## Hadoop service wrapper
#  We forcefully start hadoop! Since we need to bootstrap HDFS structure later!
#
service_manager 'hadoop' do
  supports status: true, reload: false

  manager node['pio']['service_manager']
  action :start
end

################
# HBase services
################

# HBase master
service_manager 'hbase-master' do
  supports status: true, reload: false
  user  'hadoop'
  group 'hadoop'

  # set vars before, since we use it in interpolation
  variables apache_vars(
    app: 'hbase'
  )

  exec_command "#{variables[:appdir]}/bin/hbase master start"
  exec_procregex 'org.apache.hadoop.hbase.master.HMaster'
  exec_env(
    'JAVA_HOME' => variables[:java_home]
  )

  subscribes :restart, 'apache_app[hbase]' unless provision_only?

  manager node['pio']['service_manager']
  action service_actions
end

## RegionServer is not required in non-distributed mode!!!

# HBase service (wraps all hbase services, but in our case only the master)
service_manager 'hbase' do
  supports status: true, reload: false

  manager node['pio']['service_manager']
  action :enable
end

################
# Spark services
################

# Spark master
service_manager 'spark-master' do
  supports status: true, reload: false
  user  'aml'
  group 'hadoop'

  # set vars before, since we use it in interpolation
  variables apache_vars(
    app: 'spark'
  )

  exec_command "#{variables[:appdir]}/sbin/start-spark.sh master"
  exec_procregex 'org.apache.spark.deploy.master.Master'
  exec_env(
    'JAVA_HOME' => variables[:java_home],
    'LD_LIBRARY_PATH' => "#{variables[:hadoopdir]}/lib/native"
  )

  subscribes :restart, 'apache_app[spark]' unless provision_only?

  manager node['pio']['service_manager']
  action service_actions
end

# Spark worker
service_manager 'spark-worker' do
  supports status: true, reload: false
  user  'aml'
  group 'hadoop'

  # set vars before, since we use it in interpolation
  variables apache_vars(
    app: 'spark'
  )

  exec_command "#{variables[:appdir]}/sbin/start-spark.sh worker"
  exec_procregex 'org.apache.spark.deploy.worker.Worker'
  exec_env(
    'JAVA_HOME' => variables[:java_home],
    'LD_LIBRARY_PATH' => "#{variables[:hadoopdir]}/lib/native"
  )

  subscribes :restart, 'apache_app[spark]' unless provision_only?

  manager node['pio']['service_manager']
  action service_actions
end

# Spark wrapper service
service_manager 'spark' do
  supports status: true, reload: false

  manager node['pio']['service_manager']
  action :enable
end
