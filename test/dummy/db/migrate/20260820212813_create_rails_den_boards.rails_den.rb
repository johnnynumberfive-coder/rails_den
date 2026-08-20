# This migration comes from rails_den (originally 20260820212200)
class CreateRailsDenBoards < ActiveRecord::Migration[8.1]
  def change
    create_table :rails_den_boards do |t|
      t.references :category,
                   null: false,
                   foreign_key: { to_table: :rails_den_categories }

      t.string :title, null: false
      t.string :slug, null: false
      t.text :description
      t.integer :position, null: false, default: 0
      t.boolean :enabled, null: false, default: true
      t.string :visibility, null: false, default: "public"
      t.string :icon

      t.timestamps
    end

    add_index :rails_den_boards,
              [:category_id, :slug],
              unique: true
  end
end