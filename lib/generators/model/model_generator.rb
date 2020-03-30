require 'generators/generator_helpers.rb'
module Gooey
  module Generators
    class ModelGenerator < Rails::Generators::NamedBase
      self.hide!
      source_root File.expand_path('templates', __dir__)
      include Rails::Generators::ResourceHelpers
      include Rails::Generators::Migration
      include GeneratorHelpers

      desc "Installs model, controller, views & routes for a Relation"
        def generate_model
          if(!File.exist?("app/models/#{singular_name.capitalize}.rb"))
            template "model.rb", File.join("app/models", "#{singular_name}.rb")
          end
        end
        private
        def show_action?
          return true
        end
    end
  end
end
