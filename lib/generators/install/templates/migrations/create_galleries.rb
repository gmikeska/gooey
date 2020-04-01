class CreateGalleries < ActiveRecord::Migration[6.0]
  def change
    create_table :galleries do |t|
      t.string :name
      t.timestamps
    end
  end
end
