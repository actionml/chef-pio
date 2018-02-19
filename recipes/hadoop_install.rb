#
# Cookbook Name:: pio
# Recipe:: hadoop_install
#
# Copyright 2016 ActionML LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0

include_recipe 'pio::base'

hadoop = node['pio']['hadoop']

## Install hadoop from source
#
ark 'hadoop' do
  version hadoop['version']
  checksum hadoop['sha256']
  url hadoop['url']
end

## Create hadoop file-system directories
#
dirs = %w[tmp dfs dfs/name dfs/sname dfs/data1]
dirs.map { |dir| File.join(node['pio']['libdir'], 'hadoop', dir) }.each do |path|
  directory path do
    owner 'hadoop'
    group 'hadoop'
    mode '0750'
    recursive true
    action :create
  end
end

# Generate hadoop core-site config
template 'core-site.xml' do
  source 'core-site.xml.erb'
  path File.join(node['pio']['home_prefix'], 'hadoop/etc/hadoop/core-site.xml')
  mode '0644'

  action :create
end

# Generate hadoop hdfs-site config
template 'hdfs-site.xml' do
  source 'aio-hdfs-site.xml.erb'
  path File.join(node['pio']['home_prefix'], 'hadoop/etc/hadoop/hdfs-site.xml')
  mode '0644'

  action :create
end
