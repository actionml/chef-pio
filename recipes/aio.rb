#
# Cookbook Name:: pio
# Recipe:: aio
#
# Copyright 2016-2018 ActionML LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0

#
# All-in-One PIO installation is meant to bring up all PIO service stack
# on a single machine.
#

include_recipe 'pio::default'
include_recipe 'pio::elasticsearch'

##########################################################
# Install HBase (Spark & Hadoop are installed in pio::pio)
##########################################################

apache_app 'hbase' do
  datasubdirs %w[tmp logs]
  dirowner 'hadoop'
  dirgroup 'hadoop'

  templates %w[
    conf/hbase-env.sh
    conf/hbase-site.xml
  ]
end

include_recipe 'pio::services'
include_recipe 'pio::bootstrap_hdfs'
