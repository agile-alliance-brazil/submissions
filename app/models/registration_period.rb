class RegistrationPeriod < ActiveRecord::Base
  belongs_to :conference
  
  def include? datetime
    (start_at..end_at).include? datetime
  end
end