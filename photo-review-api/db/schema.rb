# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_07_01_143913) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'albums', force: :cascade do |t|
    t.string 'name'
    t.date 'expiry_date'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'photo_user_reviews', force: :cascade do |t|
    t.bigint 'photo_id', null: false
    t.bigint 'review_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['photo_id'], name: 'index_photo_user_reviews_on_photo_id'
    t.index ['review_id'], name: 'index_photo_user_reviews_on_review_id'
  end

  create_table 'photos', force: :cascade do |t|
    t.decimal 'size'
    t.string 'dimension'
    t.bigint 'album_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['album_id'], name: 'index_photos_on_album_id'
  end

  create_table 'reviews', force: :cascade do |t|
    t.string 'name'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_foreign_key 'photo_user_reviews', 'photos'
  add_foreign_key 'photo_user_reviews', 'reviews'
  add_foreign_key 'photos', 'albums'
end
