#
# Cookbook Name:: pio
# Recipe:: bootstrap_hdfs
#
# Copyright 2018 ActionML LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0

#
# Bootstrap HDFS PIO default directory structure
#

# bootstrap-hdfs.sh helper
template "#{pio_home}/bootstrap-hdfs.sh" do
  user node['pio']['user']
  group node['pio']['user']
  mode '0755'

  backup false
  variables(
    user: 'hadoop', group: 'hadoop',
    mode: '0755',
    hadoop_binpath: "#{localdir}/hadoop/bin"
  )
end

# generate hdfs-structure file from the node attributes
file "#{pio_home}/.hdfs-structure" do
  user node['pio']['user']
  group node['pio']['user']

  backup false
  content(lazy do
    node['pio']['hdfs_structure'].inject('') do |lines, rule|
      lines << Array(rule).join(' ') + "\n"
      lines
    end
  end)
end

# populate HDFS
bash 'bootstrap initial HDFS structure' do
  creates  "#{datadir}/hadoop/dfs/data1/.bootstrapped"
  notifies :start, 'service_manager[hadoop]', :before

  cwd pio_home
  code 'cat .hdfs-structure | ./bootstrap-hdfs.sh && '\
       "touch #{datadir}/hadoop/dfs/data1/.bootstrapped"
end
