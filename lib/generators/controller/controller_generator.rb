require 'generators/generator_helpers.rb'
module Gooey
  module Generators
    class ControllerGenerator < Rails::Generators::NamedBase
      self.hide!
      source_root File.expand_path('templates', __dir__)
      include Rails::Generators::ResourceHelpers
      include Rails::Generators::Migration
      include GeneratorHelpers

      desc "Installs model, controller, views & routes for a Relation"
        def generate_model
          if(!File.exist?("app/models/#{singular_name.capitalize}.rb"))
            template "Relation.rb", File.join("app/models", "#{singular_name}.rb")
          end
        end

        def generate_controller
          if(!File.exist?("app/controllers/#{controller_file_name}_controller.rb"))
            template "controller.rb", File.join("app/controllers", "#{plural_name}_controller.rb")
          end
        end
        def add_routes
          route "resources :#{plural_name}"
        end
        private
        def show_action?
          return true
        end
    end
  end
end
