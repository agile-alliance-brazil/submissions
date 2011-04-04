class RegistrationType
  class << self
    def options_for_select
      [
        ['individual', I18n.t('registration_type.individual')],
        ['student', I18n.t('registration_type.student')]
      ]
    end
    
    def valid_values
      options_for_select.map(&:first)
    end
  end
end