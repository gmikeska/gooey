require_dependency "gooey/validators/design_validator.rb"
module Gooey
  module Models
    class Design < ActiveRecord::Base
      # table_name_prefix("gooey_")
      include ActiveModel::Validations
      validates_with Gooey::Validators::DesignValidator

      serialize :fields, Hash
      serialize :options, Hash

      def self.base(tag,template,varData,options)
        Design.create({tag:tag, content_template:template, fields:varData, options:options})
      end

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

      def append_template(toAppend,full_tag=true,renames=nil)
        if(full_tag)
          appendStr = toAppend.opening_tag+toAppend.content_template+toAppend.closing_tag
        else
          appendStr = toAppend.content_template
        end
        # if(!renames.nil?) #TODO: enamble renaming vars within appended template fragment
        #   renames.each do |key, value|
        #
        #   end
        # end
        if(toAppend.is_a? Design)
          content_template = content_template + appendStr
        elsif(toAppend.is_a? String)
          content_template = content_template + toAppend
        end
        save()
      end

      def prepend_template(toPrepend, full_tag, renames=nil)
        if(full_tag)
          prependStr = toAppend.opening_tag+toPrepend.content_template+toAppend.closing_tag
        else
          prependStr = toAppend.content_template
        end
        # if(!renames.nil?) #TODO: enamble renaming vars within prepended template fragment
        #   renames.each do |key, value|
        #
        #   end
        # end

        if(toPrepend.is_a? Design)
          content_template = prependStr + content_template
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

      def as_html(values = defaults)

        return openingTag+content(values)+closingTag
      end

      protected

        def template_vars()
          content_template.scan(scanner).flatten
        end

        def has_field(field_name)
          return !field[field_name].nil?
        end

        def opening_tag
          openingTag = "<#{tag}"

          options.each do |key, value|
            openingTag = openingTag+" "+key+"='#{value}'"
          end
          openingTag = openingTag + ">"
          return openingTag
        end

        def closing_tag
          return "</#{tag}>"
        end

        def content(values)
          c = content_template

          vars = template_vars
          vars.each do |var|
            search = varPrefix+var+varSuffix
            c = c.gsub(search, values[var.to_sym])
          end
          return c
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
  end
end
