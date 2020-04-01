module Gooey
  class FileManager < ActiveRecord::Base
      has_many_attached :files
  end
end
