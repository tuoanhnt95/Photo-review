class CreateUploads < ActiveRecord::Migration[7.0]
  def change
    create_table :uploads do |t|
      t.string :name
      t.integer :progress
      t.references :album, null: false, foreign_key: true

      t.timestamps
    end
  end
end
