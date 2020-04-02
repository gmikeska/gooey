require 'generators/generator_helpers.rb'
module Gooey
  module Generators
    class GroupModelGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('templates', __dir__)
      include Rails::Generators::ResourceHelpers
      include Rails::Generators::Migration
      include GeneratorHelpers
      desc "Generates model with the given NAME, which inherits from Gooey::Group, along with migration to create needed fields."
      def self.next_migration_number(path)
          unless @prev_migration_nr
            @prev_migration_nr = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i
          else
            @prev_migration_nr += 1
          end
          @prev_migration_nr.to_s
        end

      def copy_model
        template "models/group_model.rb", File.join("app/models", "#{singular_name}.rb")
      end

      # def copy_migrations
      #   migration_template "migrations/create_groups.rb", "db/migrate/create_#{singular_name.pluralize}.rb"
      # end
      def run_migrations
        rake("db:migrate")
      end
    end
  end
end
