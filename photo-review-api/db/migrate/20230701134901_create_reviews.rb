# frozen_string_literal: true

# CreateReviews migration
class CreateReviews < ActiveRecord::Migration[7.0]
  def change
    create_table :reviews do |t|
      t.string :name
      t.numeric :value

      t.timestamps
    end
  end
end
