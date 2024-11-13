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
require 'activerecord-import/base'

URLS = [
  'http://apple.com', 'https://apple.com', 'https://www.apple.com',
  'http://developer.apple.com', 'http://en.wikipedia.org', 'http://opensource.org',
  Faker::Internet.url
]

REFERRERS = [
  'http://apple.com', 'https://apple.com', 'https://www.apple.com',
  'http://developer.apple.com', nil, Faker::Internet.url
]

# Array to hold records for batch processing
records = []

PageView.transaction do # Wrap the whole thing in a transaction
  1_000_000.times do |i|
    # Build new records for the batch
    records << PageView.new(
      url: URLS.sample,
      referrer: REFERRERS.sample,
      viewed_at: Faker::Time.between(from: 14.days.ago, to: Time.now)
    )

    # Insert records in batches of 1000 (avoid 1 million insert one by one basically)
    if (i + 1) % 1000 == 0
      PageView.import(records)
      puts "Inserted #{i + 1} records."
      records = []
    end
  end

  # Insert any remaining records
  PageView.import(records) unless records.empty?
end
