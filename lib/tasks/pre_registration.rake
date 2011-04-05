namespace :pre_registration do

  desc "Loads all pre-registrations from the csv specified to the current conference"
  task :load => [:environment] do |filepath|
    PreRegistrationLoader.new(filepath).save
  end

end