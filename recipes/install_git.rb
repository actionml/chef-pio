#
# Cookbook Name:: pio
# Recipe:: install_git
#
# Copyright 2016 ActionML LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0


include_recipe 'git'
include_recipe 'pio::user'

pio = node['pio'][node['pio']['bundle']]
gitdir = File.join(node['pio']['rootdir'], File.basename(pio['giturl']))

# Create git directory
directory gitdir do
  user node['pio']['user']
  group node['pio']['user']
  mode '0750'
  action :create
end

# Clone pio repository
git gitdir do
  repository pio['giturl']
  revision pio['gitrev']

  user node['pio']['user']
  group node['pio']['user']

  action(pio['gitupdate'] ? :sync : :checkout)
end

link "#{node['pio']['prefix_home']}/pio" do
  to gitdir
end
