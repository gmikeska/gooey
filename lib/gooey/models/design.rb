require_dependency "gooey/validators/design_validator.rb"
module Gooey
  class Design < Gooey::Base
    cattr_accessor :default_varPrefix, :default_varSuffix, :default_varName, :default_content
    self.table_name_prefix = "gooey_"
    self.default_varPrefix = "{"
    self.default_varSuffix = "}"
    self.default_varName = "text"
    self.default_content = "Hello, world!"
    include ActiveModel::Validations
    # validates_with Gooey::Validators::DesignValidator
    serialize :fields, Hash
    serialize :subtemplates, Hash
    serialize :actions, Hash
    serialize :options, Hash
    after_initialize do |design|

      if(design.varPrefix.nil?)
        design.varPrefix = Design.default_varPrefix
      end
      if(design.varSuffix.nil?)
        design.varSuffix = Design.default_varSuffix
      end
      design.save
    end
    def self.method_missing(m, **args, &block)
      if(args[:template].nil?)
        args[:template] = Design.default_varPrefix+Design.default_varName+Design.default_varSuffix
      end
      if(args[:fields].nil?)
        args[:fields] = Hash.new
        args[:fields][Design.default_varName.to_sym] = {required:true, default:Design.default_content}
      end
      if(args[:options].nil?)
        args[:options] = Hash.new
      end
      el = self.find_or_initialize_by(tag:m, primitive:true)
      el.template = args[:template]
      el.fields = args[:fields]
      el.options = args[:options]
      return el
    end
    def resource_identifier
      self.name
    end
    def params
      data = Design.columns.collect{|c| c.name.to_sym }
      data.delete(:fields)
      data << {fields:self.field_names(true)}
      return data
    end
    def field_names(recursive = false)
      names = fields.keys
      if(recursive)
        fields.each do |name, value|
            subs = subnames_for(value[:default])
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
      firstKey = search.shift
      search.unshift(:default)
      search.unshift(firstKey)
      cursor = fields
      while(search.length > 0)
        nextKey = search.shift
        puts "- #{nextKey}"
        if((cursor.is_a?(Hash) && cursor.include?(nextKey)) || (cursor.is_a?(Array) && cursor.length > nextKey))
          cursor = cursor[nextKey]
        end
      end
      return subnames_for(cursor)
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

    def new(**args)
      args[:design_id] = self.id
      Component.new(**args)
    end
    def create(**args)
      args[:design_id] = self.id
      Component.create(**args)
    end

    def dataTypes
      data = {}
      field_names.map do |name, field|
        data[name] = get_dataType(name)
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

    # def append_template(toAppend,with_tag=true,renames=nil)
    #   if(toAppend.is_a? Design)
    #     if(with_tag)
    #       appendStr = toAppend.template
    #     else
    #       appendStr = toAppend.content_template
    #     end
    #     if(!renames.nil?) # allow renaming of variables appended to template
    #       renames.each do |key, value|
    #         appendStr = appendStr.gsub(toAppend.varPrefix+key.to_s+toAppend.varSuffix,varPrefix+value+varSuffix)
    #       end
    #     end
    #     # toAppend.fields.each do |key, value| # copy field params from appended template
    #     #   if(renames[key])                   # renaming fields to match those appended
    #     #     key = renames[key]
    #     #   end
    #     #   if(fields[key].nil?)               # only import field if it doesn't already exist
    #     #     fields[key] = value
    #     #   end
    #     # end
    #     if(!appendStr.nil?)
    #       content_template = content_template + appendStr
    #     end
    #   elsif(toAppend.is_a? String)
    #     if(!toAppend.nil?)
    #       content_template = content_template + toAppend
    #     end
    #   end
    #   save()
    # end
    #
    # def prepend_template(toPrepend, with_tag=true, renames=nil)
    #   if(toPrepend.is_a? Design)
    #     if(with_tag)
    #       prependStr = toPrepend.template
    #     else
    #       prependStr = toPrepend.content_template
    #     end
    #     if(!renames.nil?) # allow renaming of variables prepended to template
    #       renames.each do |key, value|
    #         prependStr = prependStr.gsub(toPrepend.varPrefix+key.to_s+toPrepend.varSuffix,varPrefix+value+varSuffix)
    #       end
    #     end
    #
    #     # toPrepend.fields.each do |key, value| # copy field params from prepended template
    #     #   if(renames[key])                    # renaming fields to match those appended
    #     #     key = renames[key]
    #     #   end
    #     #   if(fields[key].nil?)                # only import field if it doesn't already exist
    #     #     fields[key] = value
    #     #   end
    #     # end
    #     if(!prependStr.nil?)
    #       content_template = prependStr + content_template
    #     end
    #   elsif(toPrepend.is_a? String)
    #     if(!toPrepend.nil?)
    #       content_template = toPrepend + content_template
    #     end
    #   end
    #   # save()
    # end

    def get_dataType(field_name)
      if(field_name.is_a? Array)
        firstKey = field_name.shift
        field_name.unshift(:default)
        field_name.unshift(firstKey)
        cursor = fields
        while(field_name.length > 0)
          nextKey = field_name.shift
          if((cursor.is_a?(Hash) && cursor.include?(nextKey)) || (cursor.is_a?(Array) && cursor.length > nextKey))
            cursor = cursor[nextKey]
          end
        end
        return(typeOf(cursor))
      else
        typeOf(fields[field_name.to_sym][:default])
      end
    end

    def scanner
      Regexp.new(Regexp.escape(varPrefix)+"("+"\\S+"+")"+Regexp.escape(varSuffix))
    end
    
    def as_html(values=nil, include_scripts=true)
      if(values.nil?)
        values = defaults
      end
      return opening_tag+content(values,include_scripts)+closing_tag
    end

    def extend
      return dup
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
        if(options[:class].nil? && !functional_class.nil?)
          openingTag = openingTag+" "+"class"+"='#{functional_class}'"
        elsif(!options[:class].nil? && !functional_class.nil?)
          classes = val = val.split(' ')
          classes.unshift(functional_class)
          classes = classes.join(' ')
          openingTag = openingTag+" "+"class"+"='#{classes}'"
        end
        options.each do |key, value|
          key = key.to_s
          val = value

          if(key != "class")
            openingTag = openingTag+" "+key+"='#{val}'"
          end
        end

        openingTag = openingTag + ">"
        return openingTag
      end

      def closing_tag
        return "</#{tag}>"
      end

      def resource_scope
        return "design"
      end

      def content(values=nil,scripts=true)
        if(values.nil?)
          values = defaults
        end
        data = prepData(values)
        c = content_template
        vars = template_vars

        vars.each do |var|
          if(var.split(':')[0] == "sub")
            if(var.split(':')[1] == "scripts")
              val = renderSub(var.split(':')[1], scripts)
            else
              if(var.split(':')[2] && data[var.split(':')[2]] || !var.split(':')[2])
                val = renderSub(var.split(':')[1], data)
              elsif(var.split(':')[2] && !data[var.split(':')[2]])
                val = " "
              end
            end
          else
            val = data[var]
          end

          c = process(c,var.to_s, val)
        end
        return c
      end

    # private

      def prepData(values)
        data = Hash.new
        subcomponents = []
        values.each do |name, value|
          dtype = get_dataType(name.to_sym)
          if(dtype.include? "array")
            subType = dtype.split(':')[1]
            data[name.to_s] = []
            value.each_index do |i|
              data[name.to_s] << prepValue(value[i],subType)
            end
          else
            data[name.to_s] = prepValue(value,dtype)
          end
        end

        return data
      end
      def prepValue(value,type)
        actualType = typeOf(value)
        if(type.include?("pointer") && actualType.include?("pointer"))
          link = get_url(value)
          return link
        elsif(actualType.include? "Hash")
          return render_subcomponent(value)
        else
          return value
        end
      end
      def render_subcomponent(sub)

        res_data = retrieve_pointer(sub[:pointer])
        subData =  Hash.new
        contentOnly = sub[:contentOnly]
        subData = sub.reject {|k,v| k == :pointer || k == :contentOnly}
        if(contentOnly)
          subContent =  res_data.content(subData)
        else
          subContent =  res_data.as_html(subData)
        end
        puts subContent
        return subContent
      end
      def export
        require('json')
        JSON.pretty_generate({name:name, fields:fields,subtemplates:subtemplates, functional_class:functional_class, tag:tag})
      end
      def renderSub(subKey, data=nil)
        isPlural = (subKey == subKey.pluralize)
        isSingular = (subKey != subKey.pluralize)
        singularSubkey = subKey.singularize
        hasSingularSubtemplate = !self.subtemplates[singularSubkey].nil?
        hasPluralSubtemplate = !self.subtemplates[subKey.pluralize].nil?

        rendered = ""
        if(isPlural && hasSingularSubtemplate && hasPluralSubtemplate)
          varScanner = Regexp.new(Regexp.escape(varPrefix)+"("+"\\S+"+"):#{subKey.singularize}"+Regexp.escape(varSuffix))
          countKey = self.subtemplates[subKey].scan(varScanner).flatten.first
          if(countKey.nil?)
            countKey = subKey
          end
          if(countKey == subKey)
            token = "#{singularSubkey}"
          else
            token = "#{countKey}:#{singularSubkey}"
          end
          data[countKey.pluralize].each_index do |i|
            item = data[countKey.pluralize][i]
            line = renderSub(singularSubkey, item)
            line = process(line,"i",i.to_s)
            rendered = rendered+line
          end
          rendered = process(self.subtemplates[subKey],token,rendered)
        elsif(isPlural && !hasPluralSubtemplate && hasSingularSubtemplate)
          countKey = subKey
          data[countKey].each_index do |i|
            item = data[countKey][i]
            line = renderSub(subKey.singularize, item)
            line = process(line,"i",i.to_s)
            rendered = rendered+line
          end
        else

          rendered = process(self.subtemplates[subKey], subKey, data)
        end
        return rendered
      end
      def renderAction(actionName,onLoad = false)
        if(actionName.is_a? Array)
          scripts = []
          actionName.each do |name|
            scripts << actions[name]
          end
          renderScript(scripts, onLoad)
        else
          renderScript(actions[actionName],onLoad)
        end
      end
      def process(templateString, key, val)

          output = templateString.gsub(varPrefix+key.to_s+varSuffix,val)
          return output
      end
      def renderScript(scriptxt, onLoad = false)
        if(scriptxt.is_a? Array)
          scriptxt = scriptxt.join("\n")
          if(onLoad)
            scriptxt = %Q(
              $(()=>{
                #{scriptxt}
              })
)
          end
        end
        "<script>#{scriptxt}</script>"
      end

      def typeOf(value)
        # value = parseValue(value)
        if([true,false].include? value)
          return "boolean"
        elsif(value.is_a? Hash)
          return "Hash"
        elsif(value.is_a? Array)
          returnVal = "array"
          if(value[0])
            returnVal = returnVal+":"+typeOf(value[0])
          end
          return returnVal
        elsif value.is_a? String
          if is_pointer(value)
            return "pointer:#{parse_pointer(value)[:type]}"
          else
            begin
              uri = URI.parse(value)
              isUrl = %w( http https ).include?(uri.scheme)
            rescue URI::BadURIError
              isUrl = false
            rescue URI::InvalidURIError
              isUrl = false
            end
            if(isUrl)
              return "url"
            end
          return "string"
          end
        end
      end
  end
end
