class CreateDesigns < ActiveRecord::Migration[6.0]
  def change
    create_table :gooey_designs do |t|
      t.string :name
      t.boolean :primitive, default:false
      t.string :fields
      t.string :options
      t.string :subtemplates
      t.string :actions
      t.text :content_template
      t.string :varPrefix
      t.string :functional_class
      t.string :varSuffix
      t.string :tag
      t.timestamps
    end
  end
end
