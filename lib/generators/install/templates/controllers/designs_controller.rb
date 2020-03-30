class DesignsController < Gooey::DesignsController

  def index
  end

  def show
  end

  def new
  end

  def create
    if @design.save
      redirect_to @design, notice: 'Design was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @design.update(design_params)
      redirect_to @design, notice: 'Design was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @design.destroy
    redirect_to designs_url, notice: 'Design was successfully destroyed.'
  end
  private

   def design_params
     params.require(:design).permit(<%= editable_attribute_symbols %>)
   end

end
