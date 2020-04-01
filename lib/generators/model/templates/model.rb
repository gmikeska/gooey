<% if (singular_name.capitalize == "Gallery") %><%=%Q(class #{singular_name.capitalize} < ActiveRecord::Base
  has_many_attached :files
  def upload(params)

    if(params[:files])
          files.attach(params[:files])
    end
  end
end) %><% else %><%= %Q(class #{singular_name.capitalize} < Gooey::#{singular_name.capitalize}

end) %><% end %>
