class CreateAlbums < ActiveRecord::Migration[7.0]
  def change
    create_table :albums do |t|
      t.string :name
      t.date :expiry_date

      t.timestamps
    end
  end
end
