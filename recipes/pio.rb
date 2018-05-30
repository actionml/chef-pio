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

#
# Install PredictionIO (including core services installation)
#

include_recipe 'git'
include_recipe 'apt'
include_recipe 'java'
include_recipe 'rng-tools'
include_recipe 'maven'

include_recipe 'pio::base'
include_recipe 'pio::bash_helpers'
include_recipe 'pio::python_modules'

###################################################################
# Install Hadoop and Spark
# (these are core parts and some of their binaries used by PIO & UR
###################################################################

apache_app 'hadoop' do
  datasubdirs %w[tmp dfs dfs/name dfs/sname dfs/data1]
  dirowner 'hadoop'
  dirgroup 'hadoop'
  dirmode 0_700

  templates %w[
    etc/hadoop/core-site.xml
    etc/hadoop/hdfs-site.xml
  ]

  variables(default_variables)
end

apache_app 'spark' do
  datasubdirs %w[logs work tmp]
  dirowner 'aml'
  dirgroup 'hadoop'

  templates %w[
    conf/spark-env.sh
    conf/spark-defaults.conf
  ]

  variables(default_variables)

  files %w[sbin/start-spark.sh]
  files_mode 0_755
end

######################
# Install PredictionIO
######################

if node['pio']['pio']['install_method'] == 'binary'

  apache_app 'PredictionIO' do
    app 'pio'
    dirowner node['pio']['user']
    dirgroup node['pio']['user']
  end

elsif node['pio']['pio']['install_method'] == 'source'

  # create source directory
  directory "#{localdir}/src/pio"

  # fetch from git
  git 'pio:checkout' do
    destination "#{localdir}/src/pio"
    repository node['pio']['pio']['source']['giturl']
    revision node['pio']['pio']['source']['gitrev']
    action(node['pio']['pio']['source']['gitrev'] ? :sync : :checkout)
  end

  # create pio app directory
  directory 'pio:distdir' do
    # pio_version is only available after checkout
    path(lazy { "#{localdir}/pio-#{pio_version}" })

    owner node['pio']['user']
    group node['pio']['user']

    subscribes :create, 'execute[make-distribution.sh]', :before
    action :nothing
  end

  # build pio
  execute 'make-distribution.sh' do
    cwd "#{localdir}/src/pio"
    command './make-distribution.sh'

    subscribes :run, 'git[pio:checkout]', :immediately
    action :nothing
  end

  # untar the binary distribution
  execute 'untar pio artifact' do
    cwd "#{localdir}/src/pio"

    command(lazy do
              "tar xzf PredictionIO-#{pio_version}.tar.gz -C " \
              "#{localdir}/pio-#{pio_version} --strip-components 1"
            end)

    user  node['pio']['user']
    group node['pio']['user']

    subscribes :run, 'git[pio:checkout]', :immediately
    action :nothing
  end

  # application link to the specific version
  link "#{localdir}/pio" do
    to(lazy { "#{localdir}/pio-#{pio_version}" })
  end

else
  raise "Unsupported installation method #{node['pio']['pio']['install_method']}"
end

# link into home
link "#{pio_home}/pio" do
  to "#{localdir}/pio"
end

# write pio-env.sh configuration
template 'conf/pio-env.sh' do
  path(lazy { "#{localdir}/pio-#{pio_version}/conf/pio-env.sh" })

  variables(lazy do
    default_variables.merge(
      version: pio_version,
      es_clustername: node['pio']['conf']['es_clustername'],
      es_hosts: Array(node['pio']['conf']['es_hosts']),
      es_ports: Array(node['pio']['conf']['es_ports'])
    )
  end)
end
