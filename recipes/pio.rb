#
# Cookbook Name:: pio
# Recipe:: pio
#
# Copyright 2018 ActionML LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0

include_recipe 'pio::python_modules'

#######################
# Install and build PIO
#######################

# pio git source directory
directory "#{localdir}/src/PredictionIO" do
  user node['pio']['user']
  group node['pio']['user']
end

# fetch pio git source
git "#{localdir}/src/PredictionIO" do
  repository node['pio']['giturl']
  revision   node['pio']['gitrev']

  user node['pio']['user']
  group node['pio']['user']

  action(node['pio']['gitupdate'] ? :sync : :checkout)
end

# make distribution (runs sbt built)
execute './make-distribution.sh' do
  cwd "#{localdir}/src/PredictionIO"
  command 'bash ./make-distribution.sh'

  user node['pio']['user']
  group node['pio']['user']

  subscribes :run, "git[#{localdir}/src/PredictionIO]",
             :immediately

  not_if { ::File.exist?("#{localdir}/src/PredictionIO/PredictionIO-#{pio_version}.tar.gz") }

  action :run
end

# copy the built pio distribution
execute 'untar pio artifact' do
  cwd localdir
  command "tar xzf #{localdir}/src/PredictionIO/PredictionIO-#{pio_version}.tar.gz"

  subscribes :run, 'execute[./make-distribution.sh]', :immediately
  action :nothing
end

# populate links to pio application directory
[
  "#{localdir}/pio",
  "#{pio_home}/pio"
]
  .each do |link_path|
    link link_path do
      to "#{localdir}/PredictionIO-#{pio_version}"
    end
  end

##########################
# Install and build Mahout
##########################

# install maven
package 'maven'

# mahaout git source directory
directory "#{localdir}/src/mahout" do
  user node['pio']['user']
  group node['pio']['user']
end

# # clone mahout repository
# git mahoutdir do
#   repository mahout['giturl']
#   revision mahout['gitrev']

#   user node['pio']['system_user']
#   group node['pio']['system_user']

#   notifies :run, 'execute[build mahout]'
#   action(mahout['gitupdate'] ? :sync : :checkout)
# end

# execute 'build mahout' do
#   cwd mahoutdir

#   user node['pio']['system_user']
#   group node['pio']['system_user']

#   command 'mvn -q clean install -DskipTests'
#   action :nothing
# end

###############################
# Install Universal Recommender
###############################

# mahaout git source directory
directory "#{localdir}/src/universal-recommender" do
  user node['pio']['user']
  group node['pio']['user']
end

# # Clone pio repository
# git urdir do
#   repository ur['giturl']
#   revision ur['gitrev']

#   user node['pio']['user']
#   group node['pio']['user']

#   action(ur['gitupdate'] ? :sync : :checkout)
# end

# link "#{node['pio']['home']}/ur" do
#   to urdir
# end
