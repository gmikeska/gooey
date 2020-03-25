class CreateDesigns < ActiveRecord::Migration[6.0]
  def change
    create_table :designs do |t|
      t.string :name
      t.string :fields
      t.string :options
      t.text :content_template
      t.string :varPrefix
      t.string :varSuffix
      t.string :tag
      t.timestamps
    end
  end
end
