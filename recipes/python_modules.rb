#
# Cookbook Name:: pio
# Recipe:: python_modules
#
# Copyright 2016-2018 ActionML LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0

include_recipe 'build-essential'

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

# Install python runtime
pyruntime = python_runtime '3' do
  pip_version true
end

## Enable python from SCL for the pio user (on RHEL based systems)
#  (see https://www.softwarecollections.org/en/scls/user/rhscl/)
#
edit_file 'enable SCL python' do
  # set variables first since we use them in other properties
  variables(default_variables)

  path    "#{variables[:pio_home]}/.profile"
  content ". #{pyruntime.python_binary.scan(%r`((/[^/]+){3})`).flatten.first}/enable"

  only_if { pyruntime.python_binary.start_with?('/opt/rh/') }

  action :insert
end

python_package 'predictionio' do
  version node['pio']['pip_package_version']
end
