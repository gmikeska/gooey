require_dependency "gooey/validators/design_validator.rb"
module Gooey
  class Design < ActiveRecord::Base
    cattr_accessor :default_varPrefix, :default_varSuffix, :default_varName, :default_content
    self.table_name_prefix = "gooey_"
    self.default_varPrefix = "{"
    self.default_varSuffix = "}"
    self.default_varName = "text"
    self.default_content = "Hello, world!"
    include ActiveModel::Validations
    validates_with Gooey::Validators::DesignValidator
    serialize :fields, Hash
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
      typeOf(fields[field_name.to_sym][:default])
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

      def content(values=nil)
        if(values.nil?)
          values = defaults
        end
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
        elsif value.split('.')[0] == "file"
          returnVal = "file"
        else
          begin
            uri = URI.parse(value)
            %w( http https ).include?(uri.scheme)
          rescue URI::BadURIError
            isUrl = false
          rescue URI::InvalidURIError
            isUrl = false
          else
            isUrl = true
          end
          if(isUrl)
            return "url"
          end
          return "string"
        end
      end
  end
end
