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

  aml_aliases: <<-EHD.gsub(/^\s+/, '')
    alias hgrep="history | grep"
    alias pg="ps -e | grep"
    alias fs="#{node['pio']['home_prefix']}/hadoop/bin/hdfs dfs"
  EHD
}

# Provide pio path
ruby_block "edit .profile" do
  block do
    fed = Chef::Util::FileEdit.new("#{node['pio']['aml']['home']}/.profile")
    regex = /# Chef added! Don't edit or delete! - pip bin path/

    fed.insert_line_if_no_match(regex,
      ['', regex.source, LINES[:profile_path]].join("\n"))

    fed.write_file
  end

  only_if { File.exist?("#{node['pio']['aml']['home']}/.profile") }
end

# Provide aml handy aliases
ruby_block "edit .bashrc" do
  block do
    fed = Chef::Util::FileEdit.new("#{node['pio']['aml']['home']}/.bashrc")
    regex = /# Chef added! Don't edit or delete! - AML handy aliases/

    fed.insert_line_if_no_match(regex,
      ['', regex.source, LINES[:aml_aliases]].join("\n"))

    fed.write_file
  end

  only_if { File.exist?("#{node['pio']['aml']['home']}/.bashrc") }
end
