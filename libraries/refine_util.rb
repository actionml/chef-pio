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

require 'chef/util/editor'
require 'chef/util/file_edit'

module PIOCookbook
  ## Refine chef utils classes
  #
  refine Chef::Util::Editor do
    def remove_content(header, footer)
      replace_content(header, footer)
    end

    def replace_content(header, footer, content = nil)
      count = 0
      range = search_range(header, footer)

      if range
        @lines[range.first, r.last + 1] = Array(content)
        count = range.size
      end

      count
    end

    def append_content_if_missing(header, footer, content)
      count = 0
      range = search_range(header, footer)

      unless range
        @lines << content
        count = 1
      end

      count
    end

    private

    def search_range(header, footer)
      first = -1
      last  = -1

      @lines.each_with_index do |line, i|
        first = i if first < 0  && line.match(header)
        last  = i if first >= 0 && line.match(footer)
        return (first..last) if last > 0
      end
      nil
    end
  end

  refine Chef::Util::FileEdit do
    def insert_content_if_no_match(regex_start, regex_end, content)
      @changes = (editor.append_content_if_missing(regex_start, regex_end, content) > 0) || @changes
    end

    def search_file_delete_content(regex_start, regex_end)
      @changes = (editor.replace_content(regex_start, regex_end) > 0) || @changes
    end

    def search_file_replace_content(regex_start, regex_end, content)
      @changes = (editor.replace_content(regex_start, regex_end, content) > 0) || @changes
    end
  end
end
