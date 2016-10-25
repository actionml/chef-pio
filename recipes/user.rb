#
# Cookbook Name:: pio
# Recipe:: user
#
# Copyright 2016 ActionML LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0

user node['pio']['user'] do
  comment 'PredictionIO user'
  home "/home/#{node['pio']['user']}"
  shell '/bin/bash'
  system true
  manage_home false

  not_if { node['pio']['user'] == 'root' }
  action :create
end

## Create PIO applications common directories
#

[
  node['pio']['libdir'],
  node['pio']['rootdir'],
].
each do |dir|
  directory dir do
    recursive true
  end
end

## Create real home directory and link it to /home/$user
#
directory node['pio']['user_homedir'] do
  owner node['pio']['user']
  group node['pio']['user']
  mode '0750'

  subscribes :create, "user[#{node['pio']['user']}]"
  action :nothing
end

link "/home/#{node['pio']['user']}" do
  to "#{node['pio']['user_homedir']}"

  subscribes :create, "user[#{node['pio']['user']}]"
  action :nothing
end
