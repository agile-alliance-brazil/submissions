class RegistrationPeriod
  PRE_REGISTERED_START = Time.zone.local(2011, 4, 4)
  PRE_REGISTERED_END = Time.zone.local(2011, 4, 11, 23, 59, 59)

  EARLY_BIRD_START = Time.zone.local(2011, 4, 4)
  EARLY_BIRD_END = Time.zone.local(2011, 5, 23, 23, 59, 59)
  
  REGULAR_START = Time.zone.local(2011, 5, 24)
  REGULAR_END = Time.zone.local(2011, 6, 20, 23, 59, 59)
  
  LAST_MINUTE_START = Time.zone.local(2011, 6, 21)
  LAST_MINUTE_END = Time.zone.local(2011, 6, 27)
  
  class << self
    def pre_registered
      (PRE_REGISTERED_START..PRE_REGISTERED_END)
    end
    
    def early_bird
      (EARLY_BIRD_START..EARLY_BIRD_END)
    end
    
    def regular
      (REGULAR_START..REGULAR_END)
    end
    
    def last_minute
      (LAST_MINUTE_START..LAST_MINUTE_END)
    end
  end
end