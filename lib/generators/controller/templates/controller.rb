<%= %Q(class #{plural_name.capitalize}Controller < #{baseName}
before_action :set_#{singular_name}, only: [:show, :edit, :update, :destroy]
  layout 'application'
  #{indexMethod}
  #{render_method('show')}
  #{render_method('new')}
  #{render_method('create',
 %Q(if @#{singular_name}.save
      redirect_to @#{singular_name}, notice: '#{human_name} was successfully created.'
    else
      render :new
    end))}
  #{render_method('edit')}
  #{render_method('update',
 %Q(if @#{singular_name}.update(#{singular_name}_params)
      redirect_to @#{singular_name}, notice: '#{human_name} was successfully updated.'
    else
      render :edit
    end))}
  #{upload_method}
  #{show_files_method}
  #{render_method('destroy',
 %Q(@#{singular_name}.destroy
    redirect_to #{plural_name}_url, notice: '#{human_name} was successfully destroyed.'))}
  private

  #{render_method(singular_name+'_params',
 %Q(params.require(:#{singular_name}).permit(#{editable_attribute_symbols})))}

  #{render_method('set_'+singular_name,
 %Q(@#{singular_name} = #{singular_name.capitalize}.find(params[:id])))}
end ) %>
