module Gooey
  class ComponentsController < ActionController::Base
    before_action :set_component, only: [:show, :edit, :update, :destroy, :updateFields,:componentOnly]

    # GET /components
    # GET /components.json
    def index
      @components = component.all
    end

    # GET /components/1
    # GET /components/1.json
    def show

    end


    def componentOnly
      render partial:@component.design_type.pluralize+'/'+@component.design_name, locals:@component.field_values
    end

    def updateFields

    end

    # GET /components/new
    def new
      @component = Component.new
    end

    # GET /components/1/edit
    def edit

    end

    # POST /components
    # POST /components.json
    def create
      @component = Component.new(component_params)

      respond_to do |format|
        if @component.save
          format.html { redirect_to @component.group, notice: 'Component was successfully updated.' }
          format.json { render :show, status: :created, location: @component }
        else
          format.html { render :new }
          format.json { render json: @component.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /components/1
    # PATCH/PUT /components/1.json
    def update
      respond_to do |format|
        if @component.update(component_params)
          format.html { redirect_to @component.group, notice: 'component was successfully updated.' }
          format.json { render :show, status: :ok, location: @component }
        else
          format.html { render :edit }
          format.json { render json: @component.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /components/1
    # DELETE /components/1.json
    def destroy
      @component.destroy
      respond_to do |format|
        format.html { redirect_to group_components_url, notice: 'component was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_component
        @component = Component.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def component_params
        params.require(:component).permit(:fields, :group_id, :body)
      end

  end
end
