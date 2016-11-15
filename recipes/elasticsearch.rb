#
# Cookbook Name:: pio
# Recipe:: elasticsearch
#
# Copyright 2016 ActionML LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0

include_recipe 'elasticsearch'

elasticsearch_service 'elasticsearch' do
  action [:configure, node['pio']['provision_only'] ? :enable : :start]
end
