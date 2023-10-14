# frozen_string_literal: true

# Run: rails db:seed
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
puts 'Removing upload data...'
Upload.destroy_all

#-----------------# Create new data #-----------------#
puts 'Creating new data...'
puts 'Creating review data...'
Review.create([
                { name: 'No', value: 0 },
                { name: 'Maybe', value: 2 },
                { name: 'Yes', value: 1 }
              ])
puts 'Creating user data...'
User.create([
              {
                email: 'myspamvn@yahoo.com',
                password: '123123'
              },
              {
                email: 'photographer@hotmail.com',
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
puts "#{Album.count} albums created."

puts 'Creating photo data...'
Photo.create([
               {
                 name: 'Nikon-D3500-Shotkit-2',
                 image: 't7rmnsrnhlqhjhlqpo6y',
                 angle: 0,
                 album_id: Album.first.id
               },
               {
                 name: 'Sony-a6000-Shotkit',
                 image: 'rmsuqgcmfkqm6vfetfd0',
                 angle: 0,
                 album_id: Album.all[1].id
               },
               {
                 name: 'Fuijifilm-XH1-Shotkit',
                 image: 'bfvvvdvmazvayfepwmr1',
                 angle: 0,
                 album_id: Album.all[2].id
               }
             ])
puts "#{Photo.count} photos created."
puts 'Finished seeding!'
