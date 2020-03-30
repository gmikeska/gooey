class <%= plural_name.capitalize+"Controller < Gooey::"+plural_name.capitalize+"Controller" %>
  layout "application"
  def index
    @<%= plural_name %>= <%= singular_name.capitalize %>.all
  end

  def show
  end

  def new
  end

  def create
    if @<%= singular_name %>.save
      redirect_to @<%= singular_name %>, notice: '<%= human_name %> was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @<%= singular_name %>.update(<%= singular_name %>_params)
      redirect_to @<%= singular_name %>, notice: '<%= human_name %> was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @<%= singular_name %>.destroy
    redirect_to <%= plural_name %>_url, notice: '<%= human_name %> was successfully destroyed.'
  end
  private

   def <%= singular_name %>_params
     params.require(:<%= singular_name %>).permit(<%= editable_attribute_symbols %>)
   end

end
