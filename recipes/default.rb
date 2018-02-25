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

include_recipe 'apt::default'
include_recipe 'java::default'
include_recipe 'rng-tools::default'

include_recipe 'pio::base'
include_recipe 'pio::bash_helpers'

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

  not_if { ::File.exist?("#{localdir}/src/PredictionIO/PredictionIO-#{pio_version}.tar.gz") }

  action :run
end

# copy the built pio distribution
execute 'untar pio artifact' do
  cwd localdir
  command "tar xzf #{localdir}/src/PredictionIO/PredictionIO-#{pio_version}.tar.gz"

  subscribes :run, 'execute[./make-distribution.sh]', :immediately
  action :nothing
end

# populate links to pio application directory
[
  "#{localdir}/pio",
  "#{pio_home}/pio"
]
  .each do |link_path|
    link link_path do
      to "#{localdir}/PredictionIO-#{pio_version}"
    end
  end

##########################
# Install and build Mahout
##########################

# install maven
package 'maven'

# mahaout git source directory
directory "#{localdir}/src/mahout" do
  user node['pio']['user']
  group node['pio']['user']
end

# # clone mahout repository
# git mahoutdir do
#   repository mahout['giturl']
#   revision mahout['gitrev']

#   user node['pio']['system_user']
#   group node['pio']['system_user']

#   notifies :run, 'execute[build mahout]'
#   action(mahout['gitupdate'] ? :sync : :checkout)
# end

# execute 'build mahout' do
#   cwd mahoutdir

#   user node['pio']['system_user']
#   group node['pio']['system_user']

#   command 'mvn -q clean install -DskipTests'
#   action :nothing
# end

###############################
# Install Universal Recommender
###############################

# mahaout git source directory
directory "#{localdir}/src/universal-recommender" do
  user node['pio']['user']
  group node['pio']['user']
end

# # Clone pio repository
# git urdir do
#   repository ur['giturl']
#   revision ur['gitrev']

#   user node['pio']['user']
#   group node['pio']['user']

#   action(ur['gitupdate'] ? :sync : :checkout)
# end

# link "#{node['pio']['home']}/ur" do
#   to urdir
# end

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

## TO FIX NEED TO START PIO if AIO
# # Don't start eventserver on AIO system
# include_recipe 'pio::eventserver' unless node['pio']['aio']
