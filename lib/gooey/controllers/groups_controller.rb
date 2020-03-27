module Gooey
  # module Controllers
    class GroupsController < GooeyController
      layout false, only: [:contentOnly]
      self.abstract!

      def contentOnly

      end

      private
        # Use callbacks to share common setup or constraints between actions.
        def set_group
          current_user
          @groups = Group.all
          if(Group.where({pathSlug:params[:id]}).exists?)
              @group = Group.where({pathSlug:params[:id]})[0]
          else
              @group = Group.find(params[:id])
          end
        end

        def set_component
          set_group
          if(params[:component_id])
            @component = Component.find(params[:component_id])
          end
        end


        # Only allow a list of trusted parameters through.
        def group_params
          params.require(:group).permit(:name, :pathSlug, :content)
        end
    end
  # end
end
