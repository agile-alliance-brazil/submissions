if Rails.env == 'test'
  ActiveRecord::Schema.verbose = false
  load "#{Rails.root}/db/schema.rb"

  SeedFu.quiet = true
  SeedFu.seed
end