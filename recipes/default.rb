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

#######################
# Install and build PIO
#######################

# pio git source directory
directory "#{localdir}/src/PredictionIO" do
  user node['pio']['user']
  group node['pio']['user']
end

# fetch pio git source
git "#{localdir}/src/PredictionIO" do
  repository node['pio']['giturl']
  revision   node['pio']['gitrev']

  user node['pio']['user']
  group node['pio']['user']

  action(node['pio']['gitupdate'] ? :sync : :checkout)
end

# make distribution (runs sbt built)
execute './make-distribution.sh' do
  cwd "#{localdir}/src/PredictionIO"
  command 'bash ./make-distribution.sh'

  user node['pio']['user']
  group node['pio']['user']

  subscribes :run, "git[#{localdir}/src/PredictionIO]",
             :immediately

  environment('HOME' => pio_home)
  creates "#{localdir}/src/PredictionIO/PredictionIO-#{pio_version}.tar.gz"

  action :nothing
end

# copy the built pio distribution
execute 'untar pio artifact' do
  cwd localdir
  command "tar xzf #{localdir}/src/PredictionIO/PredictionIO-#{pio_version}.tar.gz"

  subscribes :run, 'execute[./make-distribution.sh]', :immediately
  action :nothing
end

# populate links to pio application directory
link "#{localdir}/pio" do
  to "#{localdir}/PredictionIO-#{pio_version}"
end

link "#{pio_home}/pio" do
  to "#{localdir}/pio"
end

##########################
# Install and build Mahout
##########################

# Custom mahout repo to assist broken SBT build
directory ::File.dirname(default_variables[:mahout_repo])
directory default_variables[:mahout_repo] do
  user node['pio']['user']
  group node['pio']['user']
end

# mahout git source directory
directory "#{localdir}/src/mahout" do
  user node['pio']['user']
  group node['pio']['user']
end

# clone mahout repository
git "#{localdir}/src/mahout" do
  repository node['pio']['mahout']['giturl']
  revision node['pio']['mahout']['gitrev']

  user node['pio']['user']
  group node['pio']['user']

  action(node['pio']['mahout']['gitupdate'] ? :sync : :checkout)
end

execute 'build mahout' do
  cwd "#{localdir}/src/mahout"

  user node['pio']['user']
  group node['pio']['user']

  environment(
    'HADOOP_HOME'   => default_variables[:hadoopdir],
    'SPARK_VERSION' => node['pio']['spark']['version'],
    'SCALA_VERSION' => node['pio']['scala']['version']
  )
  command 'make build deploy'

  subscribes :run, "git[#{localdir}/src/mahout]"
  action :nothing
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

## Fix build.sbt!
#
edit_file 'replace resolvers' do
  path    "#{localdir}/universal-recommender/build.sbt"

  # init vars before content
  variables(default_variables)
  content %(resolvers += "Local Repository" at "file://#{variables[:mahout_repo]}")

  regex 'resolvers += "Local Repository"'

  action :replace_line
end

###############################
# Write PIO configuration files
###############################

# Create pio config directories for  services: hadoop and hbase
%w[
  hadoop
  hbase
]
  .each do |app|
    directory "#{localdir}/pio/conf/#{app}"
  end

# generate pio-env.sh
template 'pio-env.sh' do
  path   "#{localdir}/pio/conf/pio-env.sh"
  source 'pio-env.sh.erb'
  mode   0_644

  variables(
    default_variables.merge(
      version: pio_version,
      es_clustername: node['pio']['conf']['es_clustername'],
      es_hosts: Array(node['pio']['conf']['es_hosts']),
      es_ports: Array(node['pio']['conf']['es_ports'])
    )
  )

  action :create
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

##############################################
# Start PIO Event Server on production systems
##############################################

unless node.recipe?('pio::aio')
  # Choose default file location
  default_initfile = case node['platform_family']
                     when 'debian'
                       '/etc/default/eventserver'
                     when 'rhel'
                       '/etc/sysconfig/eventserver'
                     else
                       "#{localdir}/pio/conf/default.rc"
                     end

  ## At the moment the only way to control eventserver log name and location is chdir!!!
  #
  # Create eventserver log directory
  directory '/var/log/eventserver' do
    user node['pio']['user']
    group node['pio']['user']
    mode '0755'
    action :create
  end

  # Generate default config
  template 'eventserver.default' do
    source 'services/eventserver.default.erb'
    path default_initfile
    mode 0_644
  end

  # EventServer service
  service_manager 'eventserver' do
    supports status: true, reload: false
    user  'aml'
    group 'hadoop'

    # set vars before, since we use it in interpolation
    variables(
      default_variables.merge(
        default_initfile: default_initfile
      )
    )

    exec_command "#{localdir}/pio/bin/pio eventserver"
    exec_procregex "#{localdir}/pio/assembly/pio-assembly.*"
    exec_cwd '/var/log/eventserver'

    subscribes :restart, 'template[eventserver.default]' unless provision_only?

    manager node['pio']['service_manager']
    action service_actions
  end
end
