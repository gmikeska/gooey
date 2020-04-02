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
          if(!File.exist?("app/models/#{singular_name}.rb"))
            template "model.rb", File.join("app/models", "#{singular_name}.rb")
          end
        end
        private
        def show_action?
          return true
        end
        def class_name
          return "class #{singular_name.capitalize} < #{parent_model_name}"
        end
        def parent_model_name
          if(['component','design'].include? singular_name)
            return "Gooey::#{singular_name.capitalize}"
          elsif singular_name == 'gallery'
            return 'ActiveRecord::Base'
          else
            return "Gooey::Group"
          end
        end
        def render_declared_attrs
          if(singular_name == "gallery")
            return "has_many_attached :files"
          end
        end
    end
  end
end
