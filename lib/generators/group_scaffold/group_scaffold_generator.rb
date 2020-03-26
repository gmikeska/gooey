require 'generators/generator_helpers.rb'
require 'generators/group_controller/group_controller_generator.rb'
require 'generators/group_model/group_model_generator.rb'
module Gooey
  # module Generators
    class GroupScaffoldGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('templates', __dir__)
      include Rails::Generators::ResourceHelpers
      include GeneratorHelpers
      desc "Generates model with the given NAME, which inherits from Gooey::Models::Group, along with migration to create needed fields."

        def generate_model
          if(!File.exist?("app/models/#{singular_name}.rb"))
            generate "group_model", "#{singular_name}"
          end
        end

        def generate_controller
          if(!File.exist?("app/controllers/#{controller_file_name}_controller.rb"))
          generate "group_controller", "#{singular_name}"
        end

        def copy_view_files
            directory_path = File.join("app/views", controller_file_path)
            empty_directory directory_path

            view_files.each do |file_name|
              template "views/#{file_name}.html.erb", File.join(directory_path, "#{file_name}.html.erb")
            end
        end


    end
  # end
end
