#
# Cookbook Name:: pio
# Recipe:: base
#
# Copyright 2016-2018 ActionML LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0

## Extend recipes and resource with helper methods
#
::Chef::Recipe.send(:include, PIOCookbook::HelpersMixin)
::Chef::Resource.send(:include, PIOCookbook::HelpersMixin)

###########################################################
# Data directories, PIO user configuration and FS structure
###########################################################

## Make JAVA_HOME available for the chef-client process (worked before chef13)
#
ENV['JAVA_HOME'] = default_variables[:java_home]

## Create app root directory (/usr/local) and data directory (/opt/data)
#
[
  localdir, datadir
]
  .each do |dir|
    directory(dir) { recursive true }
  end

## Create PIO user
#
user(node['pio']['user']) do
  comment 'PredictionIO user'
  home  pio_home
  shell '/bin/bash'
  system true
  manage_home false

  action :create
end

## Create data subdirectories (under /opt/data)
#
(node['pio']['datasubdirs'] || []).each do |subdir|
  directory File.join(node['pio']['datadir'], subdir) do
    owner node['pio']['user']
    group node['pio']['user']
    mode  0_750
    recursive true
    action :create
  end
end

## Create real home directory for PIO user
#
directory pio_homedir do
  owner node['pio']['user']
  group node['pio']['user']
  mode  0_750
  action :create
end

## Link /home/#{user} to the real home directory location (if required)
#
link pio_home do
  to pio_homedir
  only_if { pio_home != pio_homedir }
  action :create
end

## Link data subdirs into home
#
(node['pio']['datasubdirs'] || []).each do |path|
  link File.join(pio_home, File.basename(path)) do
    to File.join(node['pio']['datadir'], path)
  end
end

## Generate skeleton files, since manage home directory creation
#
%w[.bashrc .bash_logout .profile].each do |fname|
  skel = "/etc/skel/#{fname}"

  file File.join(pio_home, fname) do
    owner node['pio']['user']
    group node['pio']['user']

    content(lazy { File.read(skel) })

    only_if { File.exist?(skel) }
    action :create_if_missing
  end
end

#################################
# Create managed users and groups
#################################

user 'hadoop' do
  home  File.join(node['pio']['localdir'], 'hadoop')
  shell '/bin/false'
  system true
  manage_home false

  action :create
end

group 'hadoop' do
  action :modify
  members node['pio']['user']
  append true
end

################################
# Sudo configuration and ulimits
################################

## Paswordless sudo for aml user
#
sudo 'aml user' do
  name node['pio']['user']
  user node['pio']['user']
  nopasswd true
end

## Limits
#
user_ulimit node['pio']['user'] do
  filehandle_limit node['pio']['ulimit_nofile']
end

user_ulimit 'hadoop' do
  filehandle_limit node['pio']['hadoop']['nofile']
end
