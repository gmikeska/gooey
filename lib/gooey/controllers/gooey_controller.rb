require('action_controller/base')
module Gooey
  class GooeyController < ActionController::Base
    protect_from_forgery with: :exception
    
  end
end
