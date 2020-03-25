module Gooey
  class GooeyRecord < ActiveRecord::Base
    self.abstract_class = true
    table_name_prefix("gooey_")
  end
end
