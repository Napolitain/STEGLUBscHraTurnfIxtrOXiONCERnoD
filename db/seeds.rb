# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'faker'

URLS = [
  'http://apple.com', 'https://apple.com', 'https://www.apple.com',
  'http://developer.apple.com', 'http://en.wikipedia.org', 'http://opensource.org',
  Faker::Internet.url
]

REFERRERS = [
  'http://apple.com', 'https://apple.com', 'https://www.apple.com',
  'http://developer.apple.com', nil, Faker::Internet.url
]

1_000_000.times do
  PageView.create!({
                     url: URLS.sample,
                     referrer: REFERRERS.sample,
                     viewed_at: Faker::Time.between(from: 14.days.ago, to: Time.now)
                   })
  # Add batch size for performance, e.g., every 1000 records
  if PageView.count % 1000 == 0
    puts "Inserted #{PageView.count} records."
  end
end
