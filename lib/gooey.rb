require_dependency "gooey/railtie"

module Gooey
  # require_dependency "gooey/validators/design_validator.rb"
  require_dependency "gooey/models/base"
  require_dependency "gooey/models/component"
  require_dependency "gooey/models/design"
  require_dependency "gooey/models/group"


  require_dependency "gooey/controllers/gooey_controller"
  require_dependency "gooey/controllers/components_controller"
  require_dependency "gooey/controllers/designs_controller"
  require_dependency "gooey/controllers/groups_controller"

    require_relative "generators/generator_helpers"
    require_relative "generators/group_controller/group_controller_generator"
    require_relative "generators/group_model/group_model_generator"
    require_relative "generators/group/group_generator"
    require_relative "generators/install/install_generator"
    require_relative "generators/model/model_generator"
    require_relative "generators/controller/controller_generator"
    require_relative "generators/views/views_generator"


end
