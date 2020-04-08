module Gooey
  class Group < Gooey::Base
    self.table_name = "groups"
    self.abstract_class = true
    validates :name, presence: true
    serialize :group_type, String
    has_many :components

    after_initialize do |group|
      if(!slug)
        group.slug = group.name.parameterize
      end
    end

    def to_param
      slug
    end

    def add_component(component)
      component.order = components.count+1
      component.group_id = id
      component.group_type = self.class
      component.save
    end

    def as_html
      elements = components.map { |component| component.as_html }
      elements.join("").html_safe
    end
  end
end
