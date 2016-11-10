#
# Cookbook Name:: pio
# Recipe:: pio_git_install
#
# Copyright 2016 ActionML LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0

node.default['poise-python']['install_python2'] = true
node.default['poise-python']['install_python3'] = false
node.default['poise-python']['install_pypy'] = true

include_recipe 'git'
include_recipe 'poise-python'
include_recipe 'pio::base'

pio = node['pio'][node['pio']['bundle']]
piodir = File.join(node['pio']['libdir'], 'pio')

# Clone pio repository
git piodir do
  repository pio['giturl']
  revision pio['gitrev']

  user node['pio']['user']
  group node['pio']['user']

  action(pio['gitupdate'] ? :sync : :checkout)
end

link "#{node['pio']['home_prefix']}/pio" do
  to piodir
end
