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

include_recipe 'build-essential'
include_recipe 'poise-python'

## Create default /usr/bin/python -> python2.7 link,
#  since that is what PIO and friends expect.
#
execute 'update-alternatives python' do
  command 'update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1'

  not_if  { File.exist?('/usr/bin/python') }
  only_if { node['platform_family'] == 'debian' }
  action :run
end

# Install build dependenices
package_deps = {
  %w[ubuntu debian] => {
    default: %w[libssl-dev libffi-dev]
  },
  %w[centos redhat] => {
    default: %w[openssl-devel libffi-devel]
  }
}

value_for_platform(package_deps).each do |package_name|
  package package_name
end

# Install python 2 runtime
python_runtime '2' do
  setuptools_version false
end

# Install modules via pip
python_package 'requests[security]'

python_package 'predictionio' do
  version node['pio']['pypi_pio_version']
end
