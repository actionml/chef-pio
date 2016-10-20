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

userhome = File.join('/home', node['pio']['user'])
homestore = File.join(node['pio']['datadir'], "#{node['pio']['user']}-home")

user node['pio']['user'] do
  comment 'PredictionIO user'
  home userhome
  shell '/bin/bash'
  system true
  manage_home false

  action :create
end

# data base directroy (/opt/data)
directory node['pio']['databasedir'] do
  recursive true
  not_if { node['pio']['databasedir'] == '/' }

  action :create
end

# pio data dir (/opt/data/pio)
directory node['pio']['datadir'] do
  owner node['pio']['user']
  group node['pio']['user']
  mode '0755'
  action :create
end

# pio dist directory
directory File.join(node['pio']['datadir'], 'dist') do
  action :create
end


## Create user home data and link it to the actual home directory.
#  Technically user might exist (ex. if root given), so we
#  don't process directory creation and linking in this case.
#

directory homestore do
  owner node['pio']['user']
  group node['pio']['user']
  mode '0750'

  subscribes :create, "user[#{node['pio']['user']}]"
  action :nothing
end

link userhome do
  to homestore

  subscribes :create, "user[#{node['pio']['user']}]"
  action :nothing
end
