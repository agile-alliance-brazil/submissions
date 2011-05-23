namespace :registration_reminder do

  desc "Publish registration reminder for pending attendees"
  task :publish => [:environment] do
    RegistrationReminder.new.publish
  end
  
end