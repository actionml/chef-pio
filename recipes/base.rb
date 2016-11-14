#
# Cookbook Name:: pio
# Recipe:: base
#
# Copyright 2016 ActionML LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0


## Create "aml" user and setup default directory structure
#

# Create lib directory
directory node['pio']['libdir'] do
  recursive true
end

user node['pio']['aml']['user'] do
  comment 'PredictionIO user'
  home "/home/#{node['pio']['aml']['user']}"
  shell '/bin/bash'
  system true
  manage_home false

  not_if { node['pio']['aml']['user'] == 'root' }
  action :create
end

# AML project directories
%w(aml/big-data).each do |dir|
  directory File.join(node['pio']['libdir'], dir) do
    owner node['pio']['aml']['user']
    group node['pio']['aml']['user']
    mode '0750'

    recursive true
    action :create
  end
end

## Create real home directory and link it to /home/$user
#
directory node['pio']['aml']['home'] do
  owner node['pio']['aml']['user']
  group node['pio']['aml']['user']
  mode '0750'

  not_if { node['pio']['aml']['user'] == 'root' }
  action :create
end

link "/home/#{node['pio']['aml']['user']}" do
  to "#{node['pio']['aml']['home']}"

  not_if { node['pio']['aml']['user'] == 'root' }
  action :create
end

## lib links
%w(aml/big-data).each do |path|
  link "#{node['pio']['aml']['home']}/#{File.basename(path)}" do
    to File.join(node['pio']['libdir'], path)
  end
end

# Paswordless sudo for aml user
sudo 'aml user' do
  name node['pio']['aml']['user']
  user node['pio']['aml']['user']
  nopasswd true
end

# Generate skeleton files, since manage home directory creation
%w(.bashrc .bash_logout .profile).each do |fname|
  skel = "/etc/skel/#{fname}"

  file "#{node['pio']['aml']['home']}/#{fname}" do
    owner node['pio']['aml']['user']
    group node['pio']['aml']['user']

    content lazy { File.read(skel) }
    only_if { File.exist?(skel) }
    action :create_if_missing
  end
end

## Create hadoop user, since we manage "only" installation from source.
#

user 'hadoop' do
  home  "#{node['pio']['home_prefix']}/hadoop"
  shell '/bin/false'
  system true
  manage_home false

  action :create
end


group 'hadoop' do
  action :modify
  members node['pio']['aml']['user']
  append true
end
