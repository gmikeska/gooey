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

      desc "Installs controller for specified Gooey::Model"

        def generate_controller
          if(!File.exist?("app/controllers/#{controller_file_name}_controller.rb"))
            template "controller.rb", File.join("app/controllers", "#{plural_name}_controller.rb")
          end
        end

        private
        def show_action?
          return true
        end
        def baseName
          if(singular_name == "gallery")
            return "ApplicationController"
          elsif(['design','component'].include?(singular_name))
            return "Gooey::#{plural_name.capitalize}Controller"
          else
            return "Gooey::GroupsController"
          end
        end

        def indexMethod
          methodName = 'index'

          if(singular_name == "design")
            contents = "@#{plural_name} = #{singular_name.capitalize}.where({primitive:false})"
          else
            contents = "@#{plural_name} = #{singular_name.capitalize}.all"
          end
          return render_method(methodName,contents)
        end

        def upload_method
          if(singular_name == "gallery")
            methodName = "upload"
            contents =
   %Q(set_#{singular_name}
    if(params[:gallery][:files])
      @gallery.upload(params[:gallery])
    end)
        return render_method(methodName,contents)
          else
            return ""
          end
        end

        def setter_method

          if(['gallery','design','component'].include?(singular_name))
            searchParam = "id"
          else
            searchParam = 'slug'
          end
          contents =  "@#{singular_name} = #{singular_name.capitalize}.find_by #{searchParam}: params[:#{searchParam}]"
          return render_method("set_#{singular_name}",contents)
        end
        def show_files_method
          if(singular_name == "gallery")
            methodName = "show_files"
            contents =
   %Q(set_#{singular_name}
    render partial:"show_files")
        return render_method(methodName,contents)
          else
            return ""
          end
        end
    end
  end
end
