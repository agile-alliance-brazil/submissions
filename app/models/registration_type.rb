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
  end
end