module Gooey
  # module Controllers
    class DesignsController < GooeyController
      before_action :set_design, only: [:show, :edit, :update, :destroy]
      layout false, only: [:designOnly]
      # GET /designs
      # GET /designs.json
      def index
        @designs = Gooey::Design.all
      end

      # GET /designs/1
      # GET /designs/1.json
      def show
      end

      def designOnly
        set_design
        render partial:'designs/'+@design.name, locals:@design.defaults
      end

      # GET /designs/new
      def new
        @design = Gooey::Design.new
      end

      # GET /designs/1/edit
      def edit
      end

      # POST /designs
      # POST /designs.json
      def create
        @design = Gooey::Design.new(design_params)

        respond_to do |format|
          if @design.save
            format.html { redirect_to @design, notice: 'Design was successfully created.' }
            format.json { render :show, status: :created, location: @design }
          else
            format.html { render :new }
            format.json { render json: @design.errors, status: :unprocessable_entity }
          end
        end
      end

      # PATCH/PUT /designs/1
      # PATCH/PUT /designs/1.json
      def update
        respond_to do |format|
          if @design.update(design_params)
            format.html { redirect_to @design, notice: 'Design was successfully updated.' }
            format.json { render :show, status: :ok, location: @design }
          else
            format.html { render :edit }
            format.json { render json: @design.errors, status: :unprocessable_entity }
          end
        end
      end

      # DELETE /designs/1
      # DELETE /designs/1.json
      def destroy
        @design.destroy
        respond_to do |format|
          format.html { redirect_to designs_url, notice: 'Design was successfully destroyed.' }
          format.json { head :no_content }
        end
      end

      private
        # Use callbacks to share common setup or constraints between actions.
        def set_design
          if(Gooey::Design.where({name:params[:id]}).exists?)
              @design = Gooey::Design.where({name:params[:id]})[0]
          else
              @design = Gooey::Design.find(params[:id])
          end
        end

        # Only allow a list of trusted parameters through.
        def design_params
          @design = Gooey::Design.find(params[:id])
          params.require(:design).permit(:name, :fields,:options,:content_template,:tag)

        end
    end
  # end
end
