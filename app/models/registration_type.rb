class RegistrationType
  class << self
    def options_for_select
      [
        [I18n.t('registration_type.individual'), 'individual'],
        [I18n.t('registration_type.student'), 'student']
      ]
    end
    
    def valid_values
      options_for_select.map(&:second)
    end
    
    def for(value)
      "registration_type/#{value}".classify.constantize.new
    rescue
      Rails.logger.error("Invalid registration type: #{value}")
      raise "Invalid registration type: #{value}"
    end
  end
  
  class Individual
    def total
      165
    end
  end
  
  class Student
    def total
      65
    end
  end
end