require_dependency "gooey/railtie"

module Gooey
  # require_dependency "gooey/validators/design_validator.rb"
  require_dependency "gooey/models/component"
  require_dependency "gooey/models/design"
  require_dependency "gooey/models/group"

  require_dependency "gooey/controllers/components_controller"
  require_dependency "gooey/controllers/designs_controller"
  require_dependency "gooey/controllers/groups_controller"

    # require_dependency "generators/generator_helpers"
    # require_dependency "generators/group_controller/group_controller_generator"
    # require_dependency "generators/group_controller/group_model_generator"
    # require_dependency "generators/group_controller/group_scaffold_generator"


end
