<%= %Q(class #{plural_name.capitalize}Controller < #{baseName}
before_action :set_#{singular_name}, only: [:show, :edit, :update, :destroy]
  layout 'application'
  #{indexMethod}

  def show

  end

  def new
  end

  def create
    if @#{singular_name}.save
      redirect_to @#{singular_name}, notice: '#{human_name} was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @#{singular_name}.update(#{singular_name}_params)
      redirect_to @#{singular_name}, notice: '#{human_name} was successfully updated.'
    else
      render :edit
    end
  end

  #{upload_method}

  #{show_files_method}

  def destroy
    @#{singular_name}.destroy
    redirect_to #{plural_name}_url, notice: '#{human_name} was successfully destroyed.'
  end
  private

   def #{singular_name}_params
     params.require(:#{singular_name}).permit(#{editable_attribute_symbols})
   end

   def set_#{singular_name}
      @#{singular_name} = #{singular_name.capitalize}.where({id:params[:id]})[0]
    end)%><%= %Q(
end) %>
