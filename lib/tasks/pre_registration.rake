namespace :pre_registration do

  desc "Loads all pre-registrations from the csv specified in the 'filepath' variable to the current conference"
  task :load => [:environment] do 
    PreRegistrationLoader.new(File.expand_path("#{Dir.pwd}/#{ENV['filepath']}")).save
  end

end