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

# include the default recipe list
include_recipe 'java::default'
include_recipe 'pio::base'
include_recipe "pio::pio_#{node['pio']['install_method']}_install"
include_recipe 'pio::python_modules'
include_recipe 'pio::conf'
include_recipe 'pio::hadoop_install'
include_recipe 'pio::spark'
