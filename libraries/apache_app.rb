#
# Author:: Denis Baryshev (<dennybaa@gmail.com>)
# Copyright:: Copyright 2018, ActionML LLC.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#

module PIOCookbook
  class ApacheApp < Chef::Resource
    property :app, String, name_property: true
    resource_name :apache_app

    property :datasubdirs, Array, default: []

    property :datadir,   String
    property :dirowner,  String, default: 'root'
    property :dirgroup,  String, default: 'root'
    property :dirmode,   [Integer, String], default: 0_750

    property :owner, String, default: 'root'
    property :group, String, default: 'root'
    property :mode, [Integer, String], default: 0_644

    property :version,   String
    property :checksum,  String
    property :url,       String
    property :cookbook,  String

    property :templates, Array, default: []
    property :variables, Hash,  default: {}

    default_action :setup

    ## Predefined variables will be passed to templates.
    #  It doesn't make sense trying to pass appdir or localdir via variables,
    #  it probably will just ruin the correct behavior. Use properties and
    #  that what they provide, use variables for other custom variables.
    #
    def predefined
      @predefined ||= Mash.new(
        localdir: node['pio']['localdir'],
        datadir:  datadir,
        nofile:   node['pio']['ulimit_nofile'],
        appdir:   ::File.join(node['pio']['localdir'], app)
      )
    end

    ## datadir /opt/data/#{app}
    #
    def datadir
      @datadir ||= ::File.join(node['pio']['datadir'], app)
    end

    def template_name(template_path)
      "#{::File.basename(template_path)}.erb"
    end

    def template_dest(template_path)
      ::File.join(predefined[:appdir], template_path)
    end

    ## Setup action installs apache app using ark, creates app and
    #  data directories, populates configuration files from templates.
    #
    action :setup do
      # Fetch and then extract an app into its home directory (default: /usr/local/#{app})
      ark new_resource.app do
        version new_resource.version ||
                node['pio'][new_resource.app]['version']

        checksum new_resource.checksum ||
                 node['pio'][new_resource.app]['checksum']

        url new_resource.url ||
            node['pio'][new_resource.app]['url']

        prefix_home node['pio']['localdir']
      end

      # Create app datadir (default: /opt/data/#{app})
      directory new_resource.datadir do
        owner new_resource.dirowner
        group new_resource.dirgroup
        mode  new_resource.dirmode
      end

      to_create = new_resource.datasubdirs.map do |i|
        "#{new_resource.datadir}/#{i}"
      end

      # Populate subdirectories under the datadir
      to_create.each do |path|
        directory path do
          owner new_resource.dirowner
          group new_resource.dirgroup
          mode  new_resource.dirmode
        end
      end

      # Generate
      new_resource.templates.each do |template_path|
        template template_path do
          source   template_name(template_path)
          path     template_dest(template_path)

          owner    new_resource.owner
          group    new_resource.group
          mode     new_resource.mode

          cookbook new_resource.cookbook || new_resource.cookbook_name

          variables new_resource.predefined.merge(
            new_resource.variables
          )
        end
      end
    end
  end
end
