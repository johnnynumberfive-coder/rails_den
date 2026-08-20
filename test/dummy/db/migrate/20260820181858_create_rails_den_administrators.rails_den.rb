# This migration comes from rails_den (originally 20260820181527)
class CreateRailsDenAdministrators < ActiveRecord::Migration[8.1]
  def change
    create_table :rails_den_administrators do |t|
      t.references :user,
                   polymorphic: true,
                   null: false,
                   index: { unique: true }

      t.timestamps
    end
  end
end
