# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
puts 'Removing old data...'
puts 'Removing photoUserReview data...'
PhotoUserReview.destroy_all
puts 'Removing photo data...'
Photo.destroy_all
puts 'Removing album data...'
Album.destroy_all
puts 'Removing user data...'
User.destroy_all
puts 'Removing review data...'
Review.destroy_all

#-----------------# Create new data #-----------------#
puts 'Creating new data...'
puts 'Creating review data...'
Review.create([
                { name: 'No' },
                { name: 'Maybe' },
                { name: 'Yes' }
              ])
puts 'Creating user data...'
User.create([
              {
                email: 'myspamvn@yahoo.com',
                password: '123123'
              }
            ])
puts "#{User.count} users created. User info: #{User.first}"

puts 'Creating album data...'
Album.create([
               {
                 name: 'Oanh work profile 2023',
                 expiry_date: '2023-07-20',
                 user_id: User.first.id
               },
               {
                 name: 'Song artsy 2023',
                 expiry_date: '2023-07-10',
                 user_id: User.first.id
               },
               {
                 name: 'Arisa smile 2022',
                 expiry_date: '2022-07-15',
                 user_id: User.first.id
               }
             ])
# photos = Photo.create([])
# Create a photo
