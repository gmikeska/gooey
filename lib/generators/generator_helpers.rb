require 'rails/generators'
module Gooey
  module GeneratorHelpers
    attr_accessor :options, :attributes

    private

    def model_columns_for_attributes
      class_name.constantize.columns.reject do |column|
        column.name.to_s =~ /^(id|user_id|created_at|updated_at)$/
      end
    end

    def editable_attributes
      attributes ||= model_columns_for_attributes.map do |column|
        Rails::Generators::GeneratedAttribute.new(column.name.to_s, column.type.to_s)
      end
    end
    def display_attributes
      if(singular_name == "component")
        return [Rails::Generators::GeneratedAttribute.new('body', 'string'),Rails::Generators::GeneratedAttribute.new('name', 'string'),Rails::Generators::GeneratedAttribute.new('fields', 'string'),Rails::Generators::GeneratedAttribute.new('as_html', 'string')]
      elsif(singular_name == "design")
        return [Rails::Generators::GeneratedAttribute.new('name', 'string'),Rails::Generators::GeneratedAttribute.new('fields', 'string'),Rails::Generators::GeneratedAttribute.new('functional_class', 'string'),Rails::Generators::GeneratedAttribute.new('tag', 'string'),Rails::Generators::GeneratedAttribute.new('as_html', 'string')]
      else
        return editable_attributes
      end
    end
    def editable_attribute_symbols
      editable_attributes.map { |a| ":"+a.name }.join(', ')
    end

    def render_method(methodName, contents="",only=nil)
      outStr = %Q(
  def #{methodName}
    #{contents}
  end)
      if(only.nil? || only == singular_name)
        return outStr
      end
    end
  end
end
