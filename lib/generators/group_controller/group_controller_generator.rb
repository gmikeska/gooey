require 'generators/generator_helpers.rb'
module Gooey
  module Generators
    class GroupControllerGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('templates', __dir__)
      # include Rails::Generators::ResourceHelpers
      include GeneratorHelpers
      desc "Generates controller, controller_spec and views for a model with the given NAME, which inherits from Gooey::Group."

      def copy_controller
        template "group_controller.rb", File.join("app/controllers", "#{plural_name}_controller.rb")
      end

      def install_route
        route "resources :#{plural_name}"
      end

    end
  end
end
