module Gooey
  module Validators
    class DesignValidator < ActiveModel::Validator
      def validate(record)
        record.template_vars.each do |var|
          if(!record.has_field(var))
            record.errors.add(var.to_sym, :missing_field, message:"No field definition provided for var:#{var}.")
          end
        end
      end
    end
  end
end
