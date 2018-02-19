#
# Cookbook Name:: pio
# Recipe:: eventserver
#
# Copyright 2016 ActionML LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0

include_recipe 'pio::base'

# Choose default file location
case node['platform_family']
when 'debian'
  initenv = '/etc/default/eventserver'
when 'rhel'
  initenv = '/etc/sysconfig/eventserver'
end

## At the moment the only way to control eventserver log name and location is chdir!!!

# Create eventserver log directory
directory '/var/log/eventserver' do
  user node['pio']['system_user']
  group node['pio']['system_user']
  mode '0755'
  action :create
end

# Generate default config
template 'eventserver init env' do
  source 'eventserver.init.env.erb'
  path initenv
  mode '0644'

  action :create
end

service_manager 'eventserver' do
  manager node['pio']['service_manager']
  supports status: true, reload: false
  user node['pio']['system_user']
  group node['pio']['system_user']

  exec_command "#{node['pio']['home_prefix']}/pio/bin/pio eventserver"
  exec_procregex "#{node['pio']['home_prefix']}/pio/assembly/pio-assembly.*"
  exec_cwd '/var/log/eventserver'

  variables(
    home_prefix: node['pio']['home_prefix'],
    nofile: node['pio']['ulimit_nofile'],
    initenv: initenv
  )

  subscribes :restart, 'template[eventserver init env]'

  provision_only node['pio']['provision_only']
  action :start
end
