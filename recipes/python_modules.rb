#
# Cookbook Name:: pio
# Recipe:: python_modules
#
# Copyright 2016 ActionML LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0

node.default['poise-python']['install_python2'] = true
node.default['poise-python']['install_python3'] = false
node.default['poise-python']['install_pypy'] = true

include_recipe 'poise-python'
python_package 'requests[security]'

# Install pio pip module
python_package 'predictionio' do
  version node['pio']['pypi_pio_version']
end
