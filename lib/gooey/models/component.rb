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
    def field_names(recursive = false)
      names = fields.keys
      if(recursive)
        fields.each do |name, value|
            subs = subnames_for(value)
            if(!subs.nil?)
              names.delete(name)
              names << { name => subs}
            end
        end
      end
      return names
    end
    def subnames_for(obj)
      if(obj.is_a? Array)
        data = []
        obj.each do |sub|
          data << subnames_for(sub)
        end
      end
      if(obj.is_a? Hash)
        data = obj.keys
        obj.each do |name,value|
          if(value.is_a?(Hash) || value.is_a?(Array))
            data.delete(name)
            subs = {}
            subs[name] = subnames_for(value)
            data << subs
          end
        end
      end
      return data
    end
    def names_at(search)
      cursor = fields
      while(search.length > 0)
        nextKey = search.shift
        # if(cursor.is_a?(Array) && !nextKey.is_a?(Integer))
        #   byebug
        # end
        if((cursor.is_a?(Hash) && cursor.include?(nextKey)) || (cursor.is_a?(Array) && cursor.length > nextKey))
          cursor = cursor[nextKey]
        end
      end
      return subnames_for(cursor)
    end
    def field_name_for(search)
      search.each_index do |i|
        search[i] = search[i].to_s
      end
      return "component[fields[#{search.join('][')}]]"
    end
    def each_field(search=[], &block)
      rootSearch = search.clone
      fieldnames = names_at(search.clone)

      fieldnames.each_index do |i|
        item = fieldnames[i]
        search = rootSearch.clone
        if(item.is_a? Symbol)
          search = rootSearch.clone
          search << item
          name = field_name_for(search.clone)
          value = get_field(search.clone)
          label = item
          type = typeOf(search.clone)
          yield(name, value, label,type)
        elsif(item.is_a? Hash)
          search = rootSearch.clone
          search << item.keys.first
          each_field(search, &block)
        elsif(item.is_a? Array)
          search = rootSearch.clone
          search << i
          newRoot = search.clone
          item.each_index do |i|
            search = newRoot.clone
            f = item[i]
            search << f
            name = field_name_for(search.clone)
            value = get_field(search.clone)
            label = f
            type = typeOf(search.clone)
            yield(name, value, label, type, search)
          end
        end
      end
    end
    def params
      excludes = [:created_at, :updated_at]
      data = Component.columns.collect{|c| c.name.to_sym }
      data = data.reject{|f| excludes.include?(f)}
      data.delete(:fields)
      data << {fields:self.field_names(true)}
      return data
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

    def get_field(keyOrArr)
      if(keyOrArr.is_a? Array)
        cursor = fields
        while(keyOrArr.length > 0)
          nextIndex = keyOrArr.shift
          cursor = cursor[nextIndex]
        end
        return cursor
      else
        return fields[keyOrArr]
      end
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

      each_field do |name,value,label,type,search|
        if(label.to_s != "contentOnly")
          form_field_type = form_field_for_type(type)
          if(label.to_s == "pointer")
            label = "#{search.first.to_s.singularize} #{search[1]+1} Type"
          end
          outStr = outStr + render_field(formObj, name, value, form_field_type,addLabel,label)
        end
      end
      return outStr
    end

    def render_field(formObj, name, value, form_field_type, addLabel, label=nil)
      if(label.nil?)
        label = name
      end
      label = label.to_s.humanize
      fieldStr = ""
      # name = "fields[#{name}]"

      if(form_field_type == "text_field")
        fieldStr = fieldStr + "<div class='field'>"
        if(addLabel)

          fieldStr = fieldStr + formObj.label(label)
        end
        name = "fields[#{name}]"
        fieldStr = fieldStr + formObj.send(form_field_type, name.to_sym, value: value)
      elsif (form_field_type == "check_box")
        fieldStr = fieldStr + "<div class='field'>"
        if(addLabel)
          fieldStr = fieldStr + formObj.label(label)
        end
        name = "fields[#{name}]"
        value = "checked" if(value)
        fieldStr = fieldStr + formObj.send(form_field_type,name.to_sym, custom: :switch, checked: value)
      elsif (form_field_type == "link_select")
        fieldStr = fieldStr + "<div class='field'>"
        if(addLabel)
          fieldStr = fieldStr + formObj.label(label)
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
          fieldStr = fieldStr + formObj.label(label)
        end
        name = "fields[#{name}]"
        entity = parse_pointer(value)
        opts = entity[:scope].constantize.all.collect { |p| [ p.name, p.pointer ] }
        selected = value
        fieldStr = fieldStr + formObj.send("select","listGalleries".to_sym, opts, selected:selected, label:label)
        file_indexer = entity[:scope].constantize.where({slug:entity[:slug]}).first
        opts = file_indexer.filenames.map{|name| [name.to_s, file_indexer.pointer(name.to_s)]}
        fieldStr = fieldStr + formObj.send("select",name.to_sym, opts, selected:entity[:resource])
      elsif(form_field_type == "subcomponent")
        fieldStr = fieldStr + "<div class='field'>"
        thisDesign = self.design.name
        if(addLabel)
          fieldStr = fieldStr + formObj.label(label)
        end
        opts = Design.where({primitive:false}).reject{|p| p.name == thisDesign }.collect { |p| [ p.name, p.pointer ] }
        opts << ["Image",Design.where({name:"image"}).first.pointer]
        selected = value
        fieldStr = fieldStr + formObj.send("select","listDesigns".to_sym, opts, selected:selected, label:label)
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
        elsif(typeStr == "pointer:gooey")
          "subcomponent"
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
