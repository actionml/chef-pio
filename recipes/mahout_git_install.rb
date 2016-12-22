#
# Cookbook Name:: pio
# Recipe:: mahout_git_install
#
# Copyright 2016 ActionML LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0

include_recipe 'git'
include_recipe 'pio::base'

mahout = node['pio']['mahout']
mahoutdir = File.join(node['pio']['libdir'], 'mahout')

directory mahoutdir do
  owner node['pio']['aml']['user']
  group node['pio']['aml']['user']
end

# install maven
package 'maven' do
  action :install
end

# clone mahout repository
git mahoutdir do
  repository mahout['giturl']
  revision mahout['gitrev']

  user node['pio']['aml']['user']
  group node['pio']['aml']['user']

  notifies :run, 'execute[build mahout]'
  action(mahout['gitupdate'] ? :sync : :checkout)
end

execute 'build mahout' do
  cwd mahoutdir

  user node['pio']['aml']['user']
  group node['pio']['aml']['user']

  command 'mvn -q clean install -DskipTests'
  action :nothing
end
