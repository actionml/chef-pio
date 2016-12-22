#
# Cookbook Name:: pio
# Recipe:: default
#
# Copyright 2016 ActionML LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0


node.default['pio']['conf']['spark_home'] = "#{node['pio']['home_prefix']}/spark"
node.default['ark']['prefix_root'] = node['pio']['home_prefix']
node.default['ark']['prefix_bin'] = "#{node['pio']['home_prefix']}/bin"
node.default['ark']['prefix_home'] = node['pio']['home_prefix']


## Apt update && upgrade (apt cookbook resource notified)
#
execute 'apt-get upgrade' do
  command 'apt-get -fuy -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade'
  only_if { apt_installed? }

  environment(
    'DEBIAN_FRONTEND' => 'noninteractive'
  )

  action :run
  notifies :run, 'execute[apt-get update]', :before
end


include_recipe 'apt::default'
include_recipe 'java::default'
include_recipe 'pio::base'
include_recipe 'pio::bash_helpers'
include_recipe 'pio::hadoop_install'
include_recipe 'pio::spark_install'
include_recipe 'pio::python_modules'
include_recipe 'pio::pio_git_install'

# Don't install UR on production system
include_recipe 'pio::ur_git_install' if node['pio']['aio']

include_recipe 'pio::mahout_git_install'
include_recipe 'pio::conf'

# Don't start eventserver on AIO system
include_recipe 'pio::eventserver' unless node['pio']['aio']
