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

include_recipe 'build-essential'
include_recipe 'poise-python'

# Install build dependenices
package_deps = {
  %w(ubuntu debian) => {
    default: %w(libffi-dev)
  },
  %w(centos redhat) => {
    default: %w(libffi-devel)
  }
}

value_for_platform(package_deps).each do |package_name|
  package package_name
end

# Install modules via pip
python_package 'requests[security]'

python_package 'predictionio' do
  version node['pio']['pypi_pio_version']
end
