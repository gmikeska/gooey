require 'json'
module Gooey
  class Component < GooeyRecord
    serialize :fields, Hash
    attribute :css_functional_class, :string
    attribute :css_style_class, :string
    attribute :varPrefix, :string
    attribute :varSuffix, :string

    def update(data)
      # Fields are submitted to the controller by field key, so first update field, then update the rest of the model.
      set_fields(data[:fields])
      data[:fields] = field
      super(data)
    end

    def field_names
      fields.keys
    end

    def required_fields
      design.required_fields
    end

    def content_template
      design.content_template
    end

    def typeOf(field_name)
      design.get_dataType(field_name)
    end

    def design
      Design.find(design_id)
    end

    def field_types
      data = {}
      field_values.each do |key, value|
        data[key] = typeOf(value)
      end
      return data
    end

    def field_values
      data = {}
      field_names.map do |name, field|
        data[name] = field
      end
      return data
    end

    def design_name
      if(design)
        return design.name
      else
        return nil
      end
    end

    def get_field(key)
      fields[key]
    end

    def set_field(key,value)
      fields[key] = value
      save()
    end

    def set_fields(data)
      data.each do |key, value|
        set_field(key,data[key.to_sym])
      end
    end

    def group
      Group.find(group_id)
    end

    def css_classes(additional_css_classes="")
      return [css_functional_class,css_style_class,additional_css_classes].join(" ")
    end

    def as_html
      if(varPrefix.nil?)
        varPrefix = design.varPrefix
      end

      if(varSuffix.nil?)
        varSuffix = design.varSuffix
      end
      scanner = Regexp.new(Regexp.escape(varPrefix)+"("+"\\w+"+")"+Regexp.escape(varSuffix))

      openingTag = "<#{tag}"
      options.each do |key, value|
        openingTag = " "=openingTag+key+'="'+value+'"'
      end
      openingTag = openingTag + ">"

      content = content_template
      vars = content_template.scan(scanner).flatten
      vars.each do |var|
        search = varPrefix+var+varSuffix
        content = content.gsub(search, get_field[var.to_sym])
      end
      closingTag = "</#{tag}>"

      return openingTag+content+closingTag
    end

    private

      def content_template
        design.content_template
      end

      def tag
        design.tag
      end
  end
end
