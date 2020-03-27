require 'generators/generator_helpers.rb'
module Gooey
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)
      # include Rails::Generators::ResourceHelpers
      include Rails::Generators::Migration
      include GeneratorHelpers
      desc "Installs migrations for Gooey::Design and Gooey::Component"
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
      end
      def add_routes
        route %Q(scope module: 'gooey' do
  resources :designs
  resources :components
end
)
      end
      def run_migrations
        rake("db:migrate")
      end
    end
  end
end
