require_dependency "gooey/validators/design_validator.rb"
module Gooey
  # module Models
    class Design < ActiveRecord::Base
      self.table_name_prefix = "gooey_"
      include ActiveModel::Validations
      validates_with Gooey::Validators::DesignValidator
      serialize :fields, Hash
      serialize :options, Hash
      after_initialize do |design|
        design.fields.each do |name,f|
          # puts f[:default]
          f[:dataType] = typeOf(f[:default])
        end
        if(design.varPrefix.nil?)
          design.varPrefix = "{"
        end
        if(design.varSuffix.nil?)
          design.varSuffix = "}"
        end
        design.save
      end
      def self.base(tag,template,varData,options)
        Design.create({tag:tag, content_template:template, fields:varData, options:options})
      end


      def field_names
        fields.keys
      end

      def required_fields
        fields.select do |field|
          field[:required] == "true"
        end
      end

      def defaults
        data = {}
        fields.each do |name, field|
          data[name] = field[:default]
        end
        return data
      end

      def dataTypes
        data = {}
        field_names.map do |name, field|
          data[name] = field[:dataType]
        end
        return data
      end

      def add_field(name, default, required)
        newField = Hash.new()

        newField[:default] = default
        newField[:required] = required
        newField[:dataType] = typeOf(default)
        fields[name] = newField
        save()
      end

      def append_template(toAppend,full_tag=true,renames=nil)
        if(toAppend.is_a? Design)
          # if(!renames.nil?) #TODO: enamble renaming vars within appended template fragment
          #   renames.each do |key, value|
          #
          #   end
          # end
          if(full_tag)
            content_template = content_template + toAppend.template
          else
            content_template = content_template + toAppend.content_template
          end
          content_template = content_template + appendStr
        elsif(toAppend.is_a? String)
          content_template = content_template + toAppend
        end
        save()
      end

      def prepend_template(toPrepend, full_tag=true, renames=nil)
        if(toPrepend.is_a? Design)
          # if(!renames.nil?) #TODO: enamble renaming vars within prepended template fragment
          #   renames.each do |key, value|
          #
          #   end
          # end
          if(full_tag)
            content_template = toAppend.template + content_template
          else
            content_template = toAppend.content_template + content_template
          end
        elsif(toPrepend.is_a? String)
          content_template = toPrepend + content_template
        end
        save()
      end

      def get_dataType(field_name)
        field[field_name][:dataType]
      end

      def scanner
        Regexp.new(Regexp.escape(varPrefix)+"("+"\\w+"+")"+Regexp.escape(varSuffix))
      end

      def as_html(values=nil)
        if(values.nil?)
          values = defaults
        end
        return opening_tag+content(values)+closing_tag
      end

      # protected

        def template_vars()
          content_template.scan(scanner).flatten
        end

        def has_field(field_name)
          return !fields[field_name.to_sym].nil?
        end

        def template
          return opening_tag+content_template+closing_tag
        end

        def opening_tag
          openingTag = "<#{tag}"

          options.each do |key, value|
            key = key.to_s
            if(key.include? "css_")
              openingTag = openingTag+" "+key.gsub('css_',"")+"='#{value}'"
            else
              openingTag = openingTag+" "+key+"='#{value}'"
            end
          end
          openingTag = openingTag + ">"
          return openingTag
        end

        def closing_tag
          return "</#{tag}>"
        end

        def content(values=nil)
          if(values.nil?)
            values = defaults
          end
          c = content_template
          vars = template_vars
          puts "template_vars:#{template_vars}"
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
  # end
end
