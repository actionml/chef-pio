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

require 'tempfile'
require 'chef/resource/template'

module PIOCookbook
  #
  # TempfileRender is used to retrieve cookbook file or template rendered content.
  # It decides how to retrieve content by matching source with .erb extension.
  #
  # This should be used as base class to a resource which will implement built-in
  # content rendering in a tempfile.
  #
  class TempfileRender < Chef::Resource::Template
    def initialize(new_resource, run_context = nil)
      super
      # reset content_class and source
      @content_class = nil
      @source = nil
    end

    module ActionClass
      def load_current_resource
        ## We should not invoke parent template super method!
        @content_class = content_class_provider
        @current_resource ||= self.class.resource_class.new(new_resource.name)
        current_resource.path(new_resource.path)
      end

      def define_resource_requirements
        ## We should not invoke parent template super method!
        requirements.assert(:all_actions) do |a|
          a.assertion { source_given? && ::File.exist?(source_file_location) }
          a.block_action!
        end
      end

      def source_given?
        !new_resource.source.nil?
      end

      def template?
        @template ||= source_given? && new_resource.source.match(/.erb$/)
      end

      ## cookbook_file or template rendered content
      #
      #  Note: we can't reach content instance method from the action class
      #  due to chef namespace collisions (>= 12.5.1 < 14)
      #
      def rendered_tempfile
        @rendered_content ||= begin
          load_current_resource if current_resource.nil?
          if source_given?
            @content_class.new(new_resource, current_resource, @run_context).tempfile
          end
        end
      end

      def resource_cookbook
        @new_resource.cookbook || @new_resource.cookbook_name
      end

      private

      def content_class_provider
        return nil unless source_given?
        template? ? Chef::Provider::Template::Content :
                    Chef::Provider::CookbookFile::Content
      end

      def source_file_location
        @source_file_location ||= begin
          if source_given?
            store = template? ? :templates : :files
            cookbook = run_context.cookbook_collection[resource_cookbook]
            cookbook.preferred_filename_on_disk_location(run_context.node, store, @new_resource.source)
          end
        end
      end
    end

    ## Extend action class of the child resource
    #
    def self.inherited(resource_class)
      unless resource_class.ancestors.include?(Chef::Resource)
        raise TypeError,
          "Class must an ancestor of Chef::Resource. You gave #{resource_class.name} which is not."
      end
      resource_class.class_eval do
        action_class do
          include ActionClass
        end
      end
    end
  end
end
