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

unless ::File.exist?("#{datadir}/hadoop/dfs/data1/.bootstrapped")
  execute 'hdfs wait-for-daemon' do
    retries 2
    retry_delay 5

    cwd "#{localdir}/hadoop/bin"
    command './hdfs dfs -ls /'
  end

  node['pio']['hdfs']['bootstrap'].each do |path, user, mode, group|
    # defaults for hdfs directory
    user  ||= node['pio']['hdfs']['user']
    group ||= node['pio']['hdfs']['group']
    mode  ||= '0755'

    execute "hdfs mkdir: #{path}" do
      cwd "#{localdir}/hadoop/bin"
      command "./hdfs dfs -mkdir -p #{path}"
      user 'hadoop'
      group 'hadoop'
    end

    execute "hdfs chown: #{path}" do
      cwd "#{localdir}/hadoop/bin"
      command "./hdfs dfs -chown #{user}:#{group} #{path}"
      user 'hadoop'
      group 'hadoop'

      action :run
    end

    execute "hdfs chmod: #{path}" do
      cwd "#{localdir}/hadoop/bin"
      command "./hdfs dfs -chmod #{mode} #{path}"
      user 'hadoop'
      group 'hadoop'
    end
  end

  execute 'touch .bootstrapped' do
    command "touch #{datadir}/hadoop/dfs/data1/.bootstrapped"
  end
end
