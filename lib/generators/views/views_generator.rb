require 'generators/generator_helpers.rb'
module Gooey
  module Generators
    class ViewsGenerator < Rails::Generators::NamedBase
      self.hide!
      source_root File.expand_path('templates', __dir__)
      include Rails::Generators::ResourceHelpers
      include Rails::Generators::Migration
      include GeneratorHelpers

      desc "Installs model, controller, views & routes for a Relation"
        def copy_view_files
            directory_path = File.join("app/views", controller_file_path)
            empty_directory directory_path
            if(singular_name == "gallery")
              templateDirectory = "fileViews"
              names = ['index','show','edit','new','_form','_add_file','_show_files']
            elsif(['component','design'].include? singular_name)
              templateDirectory = "views"
              names = ['index','show','edit','new','_form']
            else
              templateDirectory = "groupViews"
              names = ['index','show']
            end

            names.each do |file_name|
              template "#{templateDirectory}/#{file_name}.html.erb", File.join(directory_path, "#{file_name}.html.erb")
            end
        end
        private
        def show_action?
          return true
        end
        def render_meta_link(text,destination, opts="")
          if(opts != "")
            return "<%= link_to '#{text}', #{destination}, #{opts} %>"
          else
            return "<%= link_to '#{text}', #{destination} %>"
          end

        end
        def render_td(content,indent=0,zoom=nil)
          if(!zoom.nil?)
            open = "<td style='zoom:#{zoom}'>"
          else
            open = "<td>"
          end
          close = "</td>"
          return open+content+close
        end
        def render_th(content,indent=0)
          open = "<th>"
          close = "</th>"
          return open+content+close
        end
        def render_field_list
          %Q(<% design.fields.each do |k,v| %>
            <div class="row">
            <div class="col"><code><%= k %></code></div>
            </div>
          <% end %>)
        end
    end
  end
end
