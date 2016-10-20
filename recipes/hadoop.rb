#
# Cookbook Name:: pio
# Recipe:: hadoop
#
# Copyright 2016 ActionML LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0


version = node['pio']['hadoop']['version']
filename = "hadoop-#{version}.tar.gz"
fetchurl = File.join(node['pio']['hadoop']['download_mirror'], "hadoop-#{version}", filename)

# download hadoop archive
remote_file 'hadoop-archive' do
  source fetchurl
  path "#{node['pio']['distdir']}/#{filename}"
  mode '0644'
  action :create_if_missing
end

# check sha256 sum
execute 'check-hadoop-sha256' do
  cwd node['pio']['distdir']
  command "echo #{node['pio']['hadoop']['sha256']}  #{filename} | sha256sum -c -"

  subscribes :run, 'remote_file[hadoop-archive]'
end
