#
# Cookbook Name:: pio
# Recipe:: bash_helpers
#
# Copyright 2016 ActionML LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0

include_recipe 'pio::base'

LINES = {
  profile_path: "PATH=$PATH:#{node['pio']['home_prefix']}/pio/bin",

  aml_aliases: <<-EHD.gsub(/^\s+/, ''),
    alias hgrep="history | grep"
    alias pg="ps -e | grep"
    alias fs="#{node['pio']['home_prefix']}/hadoop/bin/hdfs dfs"
    # <= AML handy aliases
  EHD

  source_pypi: <<-EHD.gsub(/^\s+/, '')
    . /opt/rh/python27/enable
    # <= sourcing pypi python
  EHD
}.freeze

# Generate .profile on systems which lack it (no skel to generate)
file 'generate .profile' do
  path   "#{node['pio']['home']}/.profile"
  owner  node['pio']['system_user']
  group  node['pio']['system_user']
  mode   0_644
  backup false

  content ''
  action :create_if_missing
end

# Provide PIO path
ruby_block 'add pio path into .profile' do
  block do
    fed = Chef::Util::FileEdit.new("#{node['pio']['home']}/.profile")
    regex = /# Chef added! Don't edit or delete! - pio bin path/

    fed.insert_line_if_no_match(regex,
                                ['', regex.source, LINES[:profile_path]].join("\n"))

    fed.write_file
  end
end

# Source pypi provided python (only on RHEL)
ruby_block 'source pypi in .profile' do
  block do
    fed = Chef::Util::FileEdit.new("#{node['pio']['home']}/.profile")
    regex = /# Chef added! Don't edit or delete! - source pypi python/

    fed.insert_line_if_no_match(regex,
                                ['', regex.source, LINES[:source_pypi]].join("\n"))

    fed.write_file
  end

  only_if { platform_family?('rhel') }
end

# Provide aml handy aliases
ruby_block 'add aml aliases into .bashrc' do
  block do
    fed = Chef::Util::FileEdit.new("#{node['pio']['home']}/.bashrc")
    regex = /# Chef added! Don't edit or delete! - AML handy aliases/

    fed.insert_line_if_no_match(regex,
                                ['', regex.source, LINES[:aml_aliases]].join("\n"))

    fed.write_file
  end

  only_if { File.exist?("#{node['pio']['home']}/.bashrc") }
end
