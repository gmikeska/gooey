class CreateComponents < ActiveRecord::Migration[6.0]
  def change
    create_table :components do |t|
      t.text :body
      t.integer :design_id
      
      t.integer :order
      t.string :fields
      t.string :options
      t.timestamps
    end
  end
end
