require 'generators/generator_helpers.rb'
module Gooey
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)
      # include Rails::Generators::ResourceHelpers
      include Rails::Generators::Migration
      include GeneratorHelpers
      desc "Installs migrations & routes for Gooey::Design and Gooey::Component"
      def self.next_migration_number(path)
          unless @prev_migration_nr
            @prev_migration_nr = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i
          else
            @prev_migration_nr += 1
          end
          @prev_migration_nr.to_s
      end

      def copy_migrations
        migration_template "migrations/create_designs.rb", "db/migrate/create_designs.rb"
        migration_template "migrations/create_components.rb", "db/migrate/create_components.rb"
        migration_template "migrations/create_galleries.rb", "db/migrate/create_galleries.rb"
        migration_template "migrations/create_groups.rb", "db/migrate/create_groups.rb"
      end
      def create_models
        generate "gooey:model", "design"
      end
      def create_component_model
        generate "gooey:model", "component"
      end
      def create_file_manager_model
        generate "gooey:model", "gallery"
      end
      def run_migrations
        rake("db:migrate")
      end
      def create_design_controller
        generate "gooey:controller", "design"
      end
      def create_component_controller
        generate "gooey:controller", "component"
      end
      def create_gallery_controller
        generate "gooey:controller", "gallery"
      end
      def create_design_views
        generate "gooey:views", "design"
      end
      def create_component_views
        generate "gooey:views", "component"
        generate "gooey:views", "gallery"
      end
      def add_routes
        route "resources :designs"
        route "resources :components"
        route "resources :galleries"
        route "get '/components/:id/preview', to: 'components#preview'"
        route "get '/galleries/:id/upload', to: 'galleries#upload'"
        route "patch '/galleries/:id/upload', to: 'galleries#upload'"
        route "get '/galleries/:id/show_files', to: 'galleries#show_files'"
      end
    end
  end
end
