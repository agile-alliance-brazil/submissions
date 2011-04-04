class Gender
  class << self
    def options_for_select
      [['M', I18n.t('gender.male')], ['F', I18n.t('gender.female')]]
    end
    
    def valid_values
      options_for_select.map(&:first)
    end
  end
end