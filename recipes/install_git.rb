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

gitdir = File.join(node['pio']['datadir'], 'PredictionIO.git')
pioattrs = node['pio'][node['pio']['bundle']]

# Clone pio repository
git gitdir do
  repository pioattrs['giturl']
  revision pioattrs['gitrev']

  user node['pio']['user']
  group node['pio']['user']

  action(pioattrs['updadte'] ? :sync : :checkout)
end

link node['pio']['homedir'] do
  to gitdir
end
