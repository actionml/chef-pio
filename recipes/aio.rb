#
# Cookbook Name:: pio
# Recipe:: aio
#
# Copyright 2016 ActionML LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0

node.default['pio']['aio'] = true
node.override["java"]["install_flavor"] = 'openjdk'

include_recipe 'pio::default'
include_recipe 'pio::hadoop'
include_recipe 'pio::hbase'
include_recipe 'pio::spark'
include_recipe 'pio::elasticsearch'
