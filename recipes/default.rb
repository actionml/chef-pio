#
# Cookbook Name:: pio
# Recipe:: default
#
# Copyright 2016 ActionML LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0


include_recipe 'java::default'
include_recipe 'pio::user'
include_recipe "pio::install_#{node['pio']['install_method']}"
include_recipe 'pio::conf'
include_recipe 'pio::hadoop'
