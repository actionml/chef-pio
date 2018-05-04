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
# Standalone PIO installation
#

include_recipe 'git'
include_recipe 'apt'
include_recipe 'java'
include_recipe 'rng-tools'
include_recipe 'chef-maven'

include_recipe 'pio::base'
include_recipe 'pio::bash_helpers'
include_recipe 'pio::python_modules'

####################################################
# Install Spark cluster computing framework.
# (the code is required to be present by PIO and UR)
####################################################

apache_app 'spark' do
  datasubdirs %w[logs work]
  dirowner 'aml'
  dirgroup 'hadoop'

  templates %w[
    conf/spark-env.sh
    conf/spark-defaults.conf
  ]

  files %w[sbin/start-spark.sh]
  files_mode 0_755
end

######################
# Install PredictionIO
######################

apache_app 'PredictionIO' do
  app 'pio'
  dirowner node['pio']['user']
  dirgroup node['pio']['user']

  templates %w[
    conf/pio-env.sh
  ]

  variables(
    default_variables.merge(
      version: node['pio']['pio']['version'],
      es_clustername: node['pio']['conf']['es_clustername'],
      es_hosts: Array(node['pio']['conf']['es_hosts']),
      es_ports: Array(node['pio']['conf']['es_ports'])
    )
  )
end

link "#{pio_home}/pio" do
  to "#{localdir}/pio"
end

#############################################################
# Write Hadoop and HBase configuration files for PredictionIO
#############################################################

# Create pio config directories for  services: hadoop and hbase
%w[
  hadoop
  hbase
]
  .each do |app|
    directory "#{localdir}/pio/conf/#{app}"
  end

# generate hadoop/hbase config files for pio
%w[
  hadoop/core-site.xml
  hbase/hbase-site.xml
]
  .each do |path|
    template "#{localdir}/pio/conf/#{path}" do
      source "#{::File.basename(path)}.erb"
      mode '0644'

      variables(default_variables)
    end
  end

###############################
# Install Universal Recommender
###############################

# UR git source directory
directory "#{localdir}/src/universal-recommender" do
  user node['pio']['user']
  group node['pio']['user']
end

# Clone pio repository
git "#{localdir}/src/universal-recommender" do
  repository node['pio']['ur']['giturl']
  revision node['pio']['ur']['gitrev']

  user node['pio']['user']
  group node['pio']['user']

  action(node['pio']['ur']['gitupdate'] ? :sync : :checkout)
end

link "#{localdir}/universal-recommender" do
  to "#{localdir}/src/universal-recommender"
end

link "#{pio_home}/ur" do
  to "#{localdir}/universal-recommender"
end

##############################################
# Start PIO Event Server on production systems
##############################################

unless node.recipe?('pio::aio')
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
      apache_vars.merge(
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

    manager node['pio']['service_manager']
    action service_actions
  end
end
