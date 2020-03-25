module Gooey
  class Design < GooeyRecord
    serialize :fields, Hash

    def field_names
      fields.keys
    end

    def required_fields
      fields.select do |field|
        field["required"] == "true"
      end
    end

    def defaults
      data = {}
      field_names.map do |name, field|
        data[name] = field["default"]
      end
      return data
    end

    def dataTypes
      data = {}
      field_names.map do |name, field|
        data[name] = field["dataType"]
      end
      return data
    end

    def add_field(name, default, required)
      newField = Hash.new()

      newField["default"] = default
      newField["required"] = required
      newField["dataType"] = typeOf(default)
      fields[name] = newField
      save()
    end

    def append_template(toAppend, renames=nil)
      # if(!renames.nil?) // TODO: enamble renaming template vars
      #   renames.each do |key, value|
      #
      #   end
      # end
      if(toAppend.is_a? Design)
        content_template = content_template + toAppend.content_template
      elsif(toAppend.is_a? String)
        content_template = content_template + toAppend
      end
      save()
    end

    def prepend_template(toPrepend, renames=nil)
      # if(!renames.nil?) // TODO: enamble renaming template vars
      #   renames.each do |key, value|
      #
      #   end
      # end

      if(toPrepend.is_a? Design)
        content_template = toPrepend.content_template + content_template
      elsif(toPrepend.is_a? String)
        content_template = toPrepend + content_template
      end

      save()
    end

    def get_dataType(field_name)
      field[field_name]["dataType"]
    end

    def scanner
      Regexp.new(Regexp.escape(varPrefix)+"("+"\\w+"+")"+Regexp.escape(varSuffix))
    end

    def as_html
      values = defaults

      vars = template_vars
      content = content_template

      vars.each do |var|
        content = content.gsub(varPrefix+var+varSuffix,values[var.to_sym])
      end
      openingTag = "<#{tag}"
      options.each do |key, value|
        openingTag = " "=openingTag+key+'="'+value+'"'
      end
      openingTag = openingTag + ">"
      closingTag = "</#{tag}>"

      return openingTag+content+closingTag
    end

    protected

    def template_vars()
      content_template.scan(scanner).flatten
    end

    private

    def typeOf(value)
      # value = parseValue(value)
      if(["true","false"].include? value)

        return "boolean"

      elsif(value[0] == "[")
        value = JSON.parse(value)
        returnVal = "array"
        if(value[0])
          returnVal = returnVal+":"+typeOf(value[0])
        end
        return returnVal
      else
        return "string"
      end
    end
end
