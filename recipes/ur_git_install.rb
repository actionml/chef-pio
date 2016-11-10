#
# Cookbook Name:: pio
# Recipe:: ur_git_install
#
# Copyright 2016 ActionML LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0

include_recipe 'git'
include_recipe 'pio::base'

ur = node['pio']['ur']
urdir = File.join(node['pio']['libdir'], 'universal-recommender')

directory urdir do
  owner node['pio']['aml']['user']
  group node['pio']['aml']['user']
end

# Clone pio repository
git urdir do
  repository ur['giturl']
  revision ur['gitrev']

  user node['pio']['aml']['user']
  group node['pio']['aml']['user']

  action(ur['gitupdate'] ? :sync : :checkout)
end

link "#{node['pio']['aml']['home']}/ur" do
  to urdir
end
