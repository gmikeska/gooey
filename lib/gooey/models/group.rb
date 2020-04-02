module Gooey
  # module Models
    class Group < ActiveRecord::Base
      self.table_name = "groups"
      self.abstract_class = true
      validates :name, presence: true
      has_many :components
      
      def add_component(component)

        component.order = components.count+1
        component.group_id = id
        component.save
      end

      def as_html
        elements = components.map { |component| component.as_html }
        elements.join("").html_safe
      end

    end
  # end
end
