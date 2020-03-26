class Create<%= singular_name.capitalize %> < ActiveRecord::Migration[6.0]
  def change
    create_table :<%= singular_name %> do |t|
      t.string :name
      t.timestamps
    end
  end
end
