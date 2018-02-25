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
require_relative 'file_util'
require_relative 'tempfile_render'

module PIOCookbook
  class EditFile < TempfileRender
    resource_name :edit_file
    default_action :insert

    property :path, String, required: true
    property :comment, String, name_property: true
    property :content, String

    property :comment_style, [
      :shell
    ], default: :shell

    TAG_STYLE = {
      shell: {
        header: '<<< ',
        footer: '>>> '
      }
    }.freeze

    action_class do
      COMMENT = "Chef added! Don't edit or delete this comment!".freeze

      def define_resource_requirements
        requirements.assert(:all_actions) do |a|
          a.assertion { new_resource.content.nil? ^ new_resource.source.nil? }
          a.failure_message "content and source properties are mutually exclusive (#{new_resource})"
          a.whyrun "content and source properties are mutually exclusive (#{new_resource})"
          a.block_action!
        end
        super
      end

      def header
        comment_string(:header)
      end

      def footer
        comment_string(:footer)
      end

      def multiline?
        @multiline ||= !!new_content.chomp.match(/\n/)
      end

      # Get instance of FileEdit
      def fed
        @fed ||= Chef::Util::FileEdit.new(new_resource.path)
      end

      def new_content
        @new_content ||= begin
          new_resource.content ? new_resource.content : IO.binread(rendered_tempfile.path)
        end
      end

      private

      def comment_string(comment_tag = '')
        case new_resource.comment_style
        when :shell
          tag = TAG_STYLE[:shell][comment_tag.to_sym]
          "# #{tag}#{new_resource.comment} (#{COMMENT})"
        end
      end
    end

    action :insert do
      if multiline?
        fed.insert_content_if_no_match(/#{Regexp.quote(header)}/,
                                       /#{Regexp.quote(footer)}/,
                                       [header, new_content.chomp, footer].join("\n"))
      else
        fed.insert_line_if_no_match(/#{Regexp.quote(comment_string)}/,
                                    [comment_string, new_content.chomp].join("\n"))
      end

      if fed.unwritten_changes?
        converge_by("Inserting content into #{new_resource.path} file") do
          fed.write_file
        end
      end
    end
  end
end
