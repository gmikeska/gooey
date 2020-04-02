require 'json'
module Gooey
  # module Models
    class Component < ActiveRecord::Base
      self.table_name_prefix = "gooey_"
      belongs_to :group
      serialize :fields, Hash
      serialize :html_options, Hash
      attribute :varPrefix, :string
      attribute :varSuffix, :string

      def name
        # Fields are submitted to the controller by field key, so first update field, then update the rest of the model.
        design.name
      end
      def update(data)
        # Fields are submitted to the controller by field key, so first update field, then update the rest of the model.
        set_fields(data[:fields])
        data[:fields] = fields
        super(data)
      end

      def field_names
        self.fields.keys
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
        field_names.each do |name|
          data[name] = get_dataType(name)
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

      def options
        # data = Hash.new
        # keys = design.options.keys.concat(html_options.keys).uniq

        # keys.each do |key|
        #   if(!html_options[key].nil?)
        #     data[key] = html_options[key]
        #   else
        #     data[key] = design.options[key]
        #   end
        # end
        return design.options
      end


      def scanner
        Regexp.new(Regexp.escape(varPrefix)+"("+"\\w+"+")"+Regexp.escape(varSuffix))
      end

      # def build_editor_with(formObj,addLabel=true)
      #   outStr = ""
      #
      #   field_types.each do |name, type|
      #     if(addLabel)
      #       outStr = outStr + formObj.label name.to_s
      #     end
      #       form_field_type = form_field_for_type(type)
      #       outStr = outStr + formObj.send form_field_type, name.to_sym, value: fields[name]
      #
      #       # outStr = outStr + formObj.send form_field_type,name.to_sym, custom: :switch, checked: fields[name]
      #
      #       formObj.form_group name.to_sym do
      #         get_field(name).each do |value|
      #           outStr = outStr + formObj.text_field name.to_sym, value:fields[name]
      #         end
      #       end
      #
      #   end
      #   return outStr
      # end

      def as_html
        if(varPrefix.nil?)
          varPrefix = design.varPrefix
        end

        if(varSuffix.nil?)
          varSuffix = design.varSuffix
        end

        return opening_tag+content+closing_tag
      end
      protected
        def content
          # c = content_template
          # vars = design.template_vars
          # vars.each do |var|
          #   search = varPrefix+var+varSuffix
          #   c = c.gsub(search, get_field[var.to_sym])
          # end
          return design.content(fields)
        end

      private

        def content_template
          design.content_template
        end
        # def form_field_for_type(typeStr)
        #   if(type == "string")
        #
        #   elsif(type == "boolean")
        #
        #   elsif(type == "array:string")
        #
        #   end
        # end
        def opening_tag
          openingTag = "<#{tag}"
          openingTag = openingTag+" "
          options.each do |key, value|
            openingTag = openingTag+" "+key+"='#{value}'"
          end
          openingTag = openingTag + ">"
          return openingTag
        end

        def closing_tag
          return "</#{tag}>"
        end

        def tag
          design.tag
        end
    end
  # end
end
