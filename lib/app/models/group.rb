module Gooey
  class ComponentGroup < GooeyRecord
    self.abstract_class = true
    has_many :components
    validates :name, presence: true

    def add_component(data)
      component = component.new()
      if(data[:design_name] || data[:component])
        data[:component] = Component.where({name:data[:design_name]})[0] if(data[:design_name] && !data[:component])
        component.component_id = data[:component].id
        defaults = component.component.defaults
        field_data = []
        component.component.field_names.each do |field_name|
          if(data[field_name.to_sym])
            field_value = data[field_name.to_sym]
          else
            field_value = defaults[field_name.to_sym]
          end
          field_data.push({name:field_name,value:field_value})
        end
        component.fields = field_data
      else
        component.body = data[:body]
      end
      component.order = components.count+1
      component.group_id = id
      component.save
    end

    def content
      elements = components.map { |component| component.content }
      elements.join("").html_safe
    end

  end
end
