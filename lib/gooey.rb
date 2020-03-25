require "gooey/version"


Dir["app/views/models"].each {|file| require file }
Dir["app/views/controllers"].each {|file| require file }
Dir["app/views/components"].each {|file| require file }
Dir["app/views/designs"].each {|file| require file }

module Gooey
  class Error < StandardError; end
  # Your code goes here...
end
