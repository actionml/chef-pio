#
# Cookbook Name:: pio
# Recipe:: stack_install
#
# Copyright 2018 ActionML LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0

######
# Recipe installs PIO stack services: hadoop, hbase, spark
######

include_recipe 'pio::base'

apache_app 'hadoop' do
  datasubdirs %w[tmp dfs dfs/name dfs/sname dfs/data1]
  dirowner 'hadoop'
  dirgroup 'hadoop'

  templates %w[
    etc/hadoop/core-site.xml
    etc/hadoop/hdfs-site.xml
  ]
end

apache_app 'hbase' do
  datasubdirs %w[tmp logs]
  dirowner 'hadoop'
  dirgroup 'hadoop'

  templates %w[
    conf/hbase-env.sh
    conf/hbase-site.xml
  ]
end

apache_app 'spark' do
  datasubdirs %w[logs work]
  dirowner 'aml'
  dirgroup 'hadoop'

  templates %w[
    conf/spark-env.sh
    conf/spark-defaults.conf
  ]
end
