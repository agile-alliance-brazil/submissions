class Attendee < ActiveRecord::Base
  belongs_to :conference
  belongs_to :user
  
  state_machine :status, :initial => :pending do
    event :confirm do
      transition [:pending, :confirmed] => :confirmed
    end

    event :expire do
      transition [:pending, :expired] => :expired
    end
    
    event :pending do
      transition [:expired, :pending] => :pending
    end
  end
end