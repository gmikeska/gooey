require "gooey/version"
require 'gooey/engine'
module Gooey
  class Error < StandardError; end

end

Dir["lib/generators/gooey"].each {|file| require file }
Dir["lib/generators/gooey/controller"].each {|file| require file }
Dir["app/models/gooey"].each {|file| require file }
Dir["app/controllers/gooey"].each {|file| require file }
Dir["app/views/gooey"].each {|file| require file }
Dir["app/validators/gooey"].each {|file| require file }
