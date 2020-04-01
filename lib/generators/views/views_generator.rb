require 'generators/generator_helpers.rb'
module Gooey
  module Generators
    class ViewsGenerator < Rails::Generators::NamedBase
      self.hide!
      source_root File.expand_path('templates', __dir__)
      include Rails::Generators::ResourceHelpers
      include Rails::Generators::Migration
      include GeneratorHelpers

      desc "Installs model, controller, views & routes for a Relation"
        def copy_view_files
            directory_path = File.join("app/views", controller_file_path)
            empty_directory directory_path
            if(singular_name == "gallery")
              templateDirectory = "fileViews"
              names = ['index','show','edit','new','_form','_add_file']
            else
              templateDirectory = "views"
              names = ['index','show','edit','new','_form']
            end

            names.each do |file_name|
              template "#{templateDirectory}/#{file_name}.html.erb", File.join(directory_path, "#{file_name}.html.erb")
            end
        end
        private
        def show_action?
          return true
        end
    end
  end
end
