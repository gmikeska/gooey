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

            ['index','show','edit','new','_form'].each do |file_name|
              template "views/#{file_name}.html.erb", File.join(directory_path, "#{file_name}.html.erb")
            end
        end
        private
        def show_action?
          return true
        end
    end
  end
end
