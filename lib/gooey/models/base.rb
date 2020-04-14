require 'json'
module Gooey
  class Base < ActiveRecord::Base
    self.abstract_class = true

    def resource_type
      "gooey"
    end
    def params
      data = self.class.columns.collect{|c| c.name.to_sym }
      return data
    end
    def resource_scope
      self.class.name.downcase
    end
    def resource_identifier
      to_param
    end
    def pointer
      return "#{resource_type}:#{resource_scope}:#{resource_identifier}"
    end
    def url
      Rails.application.routes.url_helpers.polymorphic_url(self, only_path: true)
    end
    def get_url(pointer)

      puts pointer

      if(pointer.include? "file")
        target = parse_pointer(pointer)
        return target[:scope].capitalize.constantize.where({slug:target[:slug]}).first.get_url(target[:resource])
      else
        return retrieve_pointer(pointer).url
      end
    end
    def retrieve_pointer(pointer)
      pointer = parse_pointer(pointer)
        searchScope = pointer[:scope].capitalize.constantize

      if(searchScope.columns.to_a.select {|c| c.name == "slug" || c.name == "name"}.count == 0)
        return searchScope.find(pointer[:slug])
      else

        if(searchScope.to_s == "Design")
          return searchScope.where({name:pointer[:slug]}).first
        elsif(pointer[:type] == "file")
          return (searchScope.where({slug:pointer[:slug]}).first.files.select {|f| f.filename == pointer[:resource]}).first
        else
          return searchScope.where({slug:pointer[:slug]}).first
        end
      end
    end
    def parse_pointer(pointer)
      parts = pointer.split(":")
      if(parts[0] == "file")
        data = {type:parts[0], scope:"Gallery", slug:parts[1], resource:parts[2]}
      else
        data = {type:parts[0], scope:parts[1].capitalize, slug:parts[2]}
      end
      return data
    end
    def is_pointer(pointer)
      return !!pointer.match(/(\S+):(\S+):(\S+)/)
    end
  end
end
