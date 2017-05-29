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

include_recipe 'git'
include_recipe 'pio::base'

## Pull apache pio, run sbt built and untar the created artifact of pio
#

pio = node['pio'][node['pio']['bundle']]
pio_distdir = File.join(node['pio']['libdir'], 'pio-src')
piover = pio['gitrev'].sub(/^v/, '')

# clone pio repository
directory pio_distdir do
  owner node['pio']['aml']['user']
  group node['pio']['aml']['user']
end

git pio_distdir do
  repository pio['giturl']
  revision pio['gitrev']

  user node['pio']['aml']['user']
  group node['pio']['aml']['user']

  action(pio['gitupdate'] ? :sync : :checkout)
end

# make distribution, run sbt built
execute 'make-distribution.sh' do
  cwd pio_distdir
  command 'bash make-distribution.sh'

  user node['pio']['aml']['user']
  group node['pio']['aml']['user']

  subscribes :run, "git[#{pio_distdir}]", :immediately
  action :nothing
end

# copy the built pio distribution
execute 'untar pio artifact' do
  cwd node['pio']['libdir']
  command "tar xzf #{pio_distdir}/PredictionIO-#{piover}.tar.gz"

  subscribes :run, "git[#{pio_distdir}]", :immediately
  action :nothing
end

link "#{node['pio']['libdir']}/pio" do
  to "PredictionIO-#{piover}"
end

link "#{node['pio']['home_prefix']}/pio" do
  to ::File.join(node['pio']['libdir'], "PredictionIO-#{piover}")
end
