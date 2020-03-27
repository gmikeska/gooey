class Create<%= plural_name.capitalize %> < ActiveRecord::Migration[6.0]
  def change
    create_table :<%= plural_name %> do |t|
      <% args.each do |arg| %>
      <% type = arg.split(':')[1]; col = arg.split(':')[0] %>
      <%= "t.#{type} :#{col}" %>
      <% end %>
      t.timestamps
    end
  end
end
