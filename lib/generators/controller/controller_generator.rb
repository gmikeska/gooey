require 'generators/generator_helpers.rb'
module Gooey
  module Generators
    class ControllerGenerator < Rails::Generators::NamedBase
      self.hide!
      def initialize(*args)
        @base = args[0][0]
        super(*args)
      end
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
        def baseName
          if(@base == "gallery")
            return "ApplicationController"
          else
            return "Gooey::#{plural_name.capitalize}Controller"
          end
        end
        def indexMethod
          if(singular_name == "design")

            outStr = %Q(
  def index
    @#{plural_name} = #{singular_name.capitalize}.where({primitive:false})
  end)
          else
            outStr = %Q(
  def index
   @#{plural_name} = #{singular_name.capitalize}.all
  end)
          end
          return outStr
        end
        def upload_method
          if(singular_name == "gallery")

            outStr = %Q(
  def upload
    set_#{singular_name}
    render partial:"add_file"
  end)
          else
            outStr = ""
          end
          return outStr
        end
    end
  end
end
