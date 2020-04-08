require 'json'
module Gooey
  class Component < Gooey::Base
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
        data[name] = typeOf(name)
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
        if(typeOf(key) == "boolean")
          if(value == "0" || value == 0 )
            value = false
          elsif(value == "1" ||  value == 1)
            value = true
          end
        end
        set_field(key,value)
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

    def build_editor_with(formObj,addLabel=true)
      outStr = ""

      field_types.each do |name, type|
        # outStr = outStr + "<div class='field'>"

        if(type.include? "array")
          types = type.split(':')
          types.delete('array')
          type = types.join(':')
          form_field_type = form_field_for_type(type)
          if(addLabel)
            outStr = outStr + formObj.label(name.to_s)
          end
          if(formObj.respond_to? "form_group")
            outStr = outStr + formObj.form_group(name.to_sym) do
              fields[name].each do |field|
                render_field(formObj, name, field, form_field_type,false, true)
              end
            end
          else
            fields[name].each do |field|
              outStr = outStr + render_field(formObj, name, field, form_field_type,false,true)
              outStr = outStr + "<br>"
            end
          end
          outStr = outStr + "<button>Add #{name.to_s.singularize}</button>"
        else
          form_field_type = form_field_for_type(type)
          outStr = outStr + render_field(formObj, name, fields[name], form_field_type,addLabel)
        end
      end
      return outStr
    end

    def render_field(formObj, name, value, form_field_type, addLabel, asArray=false)
      fieldStr = ""
      # name = "fields[#{name}]"
      if(asArray)
        name = name.to_s+"[]"
      end
      if(form_field_type == "text_field")
        fieldStr = fieldStr + "<div class='field'>"
        if(addLabel)
          fieldStr = fieldStr + formObj.label(name.to_s)
        end
        name = "fields[#{name}]"
        fieldStr = fieldStr + formObj.send(form_field_type, name.to_sym, value: value)
      elsif (form_field_type == "check_box")
        fieldStr = fieldStr + "<div class='field'>"
        if(addLabel)
          fieldStr = fieldStr + formObj.label(name.to_s)
        end
        name = "fields[#{name}]"
        value = "checked" if(value)
        fieldStr = fieldStr + formObj.send(form_field_type,name.to_sym, custom: :switch, checked: value)
      elsif (form_field_type == "link_select")
        fieldStr = fieldStr + "<div class='field'>"
        if(addLabel)
          fieldStr = fieldStr + formObj.label(name.to_s)
        end
        name = "fields[#{name}]"
        pointerLink = is_pointer(value)
        if(pointerLink)
          entity = parse_pointer(value)
          opts = entity[:scope].constantize.all.collect { |p| [ p.name, p.pointer ] }
          opts << ["External link...","link"]
          selected = value
          exLink = nil
          fieldStr = fieldStr + formObj.send("select",name.to_sym, opts, selected:selected)
        else
          # opts = group_type.constantize.all.collect { |p| [ p.name, p.pointer ] }
          exLink = value
          fieldStr = fieldStr + formObj.send("text_field",name.to_sym, label:"External link", class:"addCloseToSelectBtn", value:exLink)
        end
      elsif (form_field_type == "file_select")
        fieldStr = fieldStr + "<div class='field addCloseBtn'>"
        if(addLabel)
          fieldStr = fieldStr + formObj.label(name.to_s)
        end
        name = "fields[#{name}]"
        entity = parse_pointer(value)
        opts = entity[:scope].constantize.all.collect { |p| [ p.name, p.pointer ] }
        selected = value
        fieldStr = fieldStr + formObj.send("select","listGalleries".to_sym, opts, selected:selected)
        file_indexer = entity[:scope].constantize.where({slug:entity[:slug]}).first
        opts = file_indexer.filenames.map{|name| [name.to_s, file_indexer.pointer(name.to_s)]}
        fieldStr = fieldStr + formObj.send("select",name.to_sym, opts, selected:entity[:resource])
      end
      fieldStr = fieldStr + "</div>"

      return fieldStr
    end
    def as_html
      if(varPrefix.nil?)
        varPrefix = design.varPrefix
      end

      if(varSuffix.nil?)
        varSuffix = design.varSuffix
      end

      return opening_tag+content+closing_tag
    end
    def renderAction(actionName,onLoad = false)
      design.renderAction(actionName,onLoad)
    end
    # protected
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
      def form_field_for_type(typeStr)
        if(typeStr == "string")
          "text_field"
        elsif(typeStr == "boolean")
          "check_box"
        elsif(typeStr == "pointer:group")
          "link_select"
        elsif(typeStr == "pointer:file")
          "file_select"
        end
      end
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
end
