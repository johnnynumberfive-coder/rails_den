# This migration comes from rails_den (originally 20260820205806)
class CreateRailsDenCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :rails_den_categories do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.text :description
      t.integer :position, null: false, default: 0
      t.boolean :enabled, null: false, default: true
      t.string :visibility, null: false, default: "public"

      t.timestamps
    end

    add_index :rails_den_categories, :slug, unique: true
  end
end
