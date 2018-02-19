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

pio_distdir = File.join(node['pio']['libdir'], 'pio-src')
pio_version = node['pio']['gitrev'].sub(/^v/, '')

# clone pio repository
directory pio_distdir do
  owner node['pio']['system_user']
  group node['pio']['system_user']
end

# update certificates on debian platform
execute 'update-certificates' do
  command '/var/lib/dpkg/info/ca-certificates-java.postinst configure'

  only_if { node['platform_family'] == 'debian' }
  action :run
end

git pio_distdir do
  repository node['pio']['giturl']
  revision node['pio']['gitrev']

  user node['pio']['system_user']
  group node['pio']['system_user']

  action(node['pio']['gitupdate'] ? :sync : :checkout)
end

# make distribution, run sbt built
execute 'make-distribution.sh' do
  cwd pio_distdir
  command 'bash make-distribution.sh'

  user node['pio']['system_user']
  group node['pio']['system_user']

  subscribes :run, "git[#{pio_distdir}]", :immediately
  action :nothing
end

# copy the built pio distribution
execute 'untar pio artifact' do
  cwd node['pio']['libdir']
  command "tar xzf #{pio_distdir}/PredictionIO-#{pio_version}.tar.gz"

  subscribes :run, "git[#{pio_distdir}]", :immediately
  action :nothing
end

link "#{node['pio']['libdir']}/pio" do
  to "PredictionIO-#{pio_version}"
end

link "#{node['pio']['home_prefix']}/pio" do
  to ::File.join(node['pio']['libdir'], "PredictionIO-#{pio_version}")
end
