#
# Cookbook Name:: pio
# Recipe:: bash_helpers
#
# Copyright 2016-2018 ActionML LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0

include_recipe 'pio::base'

## Generate .profile on systems which lack it (no skel to generate)
#
file 'generate .profile' do
  path   "#{pio_home}/.profile"
  owner  node['pio']['user']
  group  node['pio']['user']
  mode   0_644
  backup false

  content ''
  action :create_if_missing
end

## Added pio bin directory into PATH (~/.profile)
#
edit_file 'PIO bin path' do
  # set variables first since we use them in other properties
  variables(default_variables)

  path    "#{variables[:pio_home]}/.profile"
  content "PATH=$PATH:#{variables[:localdir]}/pio/bin"

  action :insert
end

## PIO stack parts homes into profile
#
edit_file 'PIO apps homes' do
  path    "#{pio_home}/.profile"

  content <<-EHD.gsub(/^\s+/m, '')
    HADOOP_HOME=#{localdir}/hadoop
    HBASE_HOME=#{localdir}/hbase
    SPARK_HOME=#{localdir}/spark
  EHD

  action :insert
end

## Populate ~/.bashrc
#
edit_file 'Handy AML bashrc aliases' do
  # set variables first since we use them in other properties
  variables(default_variables)

  path   "#{variables[:pio_home]}/.bashrc"
  source 'bashrc.erb'

  only_if { ::File.exist? "#{variables[:pio_home]}/.bashrc" }

  action :insert
end
