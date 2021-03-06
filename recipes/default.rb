#
# Cookbook Name:: pio
# Recipe:: default
#
# Copyright 2016-2018 ActionML LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0

#
# Standalone PIO machine setup
#

########################
### Install PredictionIO
########################
include_recipe 'pio::pio'

#############################################################
# Write Hadoop and HBase configuration files for PredictionIO
#############################################################

# create hbase configuration directory (on non-AIO machines)
directory "#{localdir}/hbase/conf" do
  recursive true
  not_if { node.recipe? 'pio::aio' }
end

# write template since (hbase won't be install on non-AIO)
template "#{localdir}/hbase/conf/hbase-site.xml" do
  variables(default_variables)
  notifies :restart, 'service_manager[eventserver]'
  not_if { node.recipe? 'pio::aio' }
end

# Create pio config directories for  services: hadoop and hbase
%w[
  hadoop
  hbase
]
  .each do |app|
    directory "#{localdir}/pio/conf/#{app}"
  end

# Links configuration files into pio/conf
%w[
  hadoop/etc/hadoop/core-site.xml
  hbase/conf/hbase-site.xml
]
  .each do |path|
    # convert first/XXX/last -> %w[first last]
    parts = path.split('/')
    parts.slice!(1..-2)

    link path do
      target_file ::File.join(localdir, 'pio', 'conf', *parts)
      to ::File.join(localdir, path)
    end
  end

###############################
# Install Universal Recommender
###############################

# UR git source directory

directory "#{pio_home}/ur" do
  user node['pio']['user']
  group node['pio']['user']
end

# Clone pio repository
git "#{pio_home}/ur" do
  repository node['pio']['ur']['giturl']
  revision node['pio']['ur']['gitrev']

  user node['pio']['user']
  group node['pio']['user']

  action(node['pio']['ur']['gitupdate'] ? :sync : :checkout)
end

########################
# Start PIO Event Server
########################

environment_file =
  value_for_platform_family(
    'debian' => '/etc/default/pio',
    'rhel'   => '/etc/sysconfig/pio'
  )

# Create eventserver log directory
directory '/var/log/eventserver' do
  user node['pio']['user']
  group node['pio']['user']
  mode '0755'
  action :create
end

# Generate default config
template 'pio.default' do
  source 'services/pio.default.erb'
  path environment_file
  variables(
    eventserver_port: node['pio']['conf']['eventserver_port'],
    predictionserver_port: node['pio']['conf']['predictionserver_port']
  )
  mode 0_644
end

# EventServer service
service_manager 'eventserver' do
  supports status: true, reload: false
  user  'aml'
  group 'hadoop'

  # set vars before, since we use it in interpolation
  variables(
    apache_vars(
      app: 'pio',
      environment_file: environment_file,
      logdir: '/var/log/eventserver'
    )
  )

  exec_command "#{variables[:piodir]}/bin/pio eventserver"
  exec_procregex "#{variables[:piodir]}/assembly/pio-assembly.*"
  exec_env(
    'PIO_LOG_DIR' => variables[:logdir]
  )

  subscribes :restart, 'template[eventserver.default]' unless provision_only?
  subscribes :restart, 'template[conf/pio-env.sh]' unless provision_only?

  manager node['pio']['service_manager']

  # disable eventserver startup
  action node.recipe?('pio::aio') ? :disable : :enable
end
