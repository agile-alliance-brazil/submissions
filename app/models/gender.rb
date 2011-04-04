class Gender
  class << self
    def options_for_select
      [[I18n.t('gender.male'), 'M'], [I18n.t('gender.female'), 'F']]
    end
    
    def valid_values
      options_for_select.map(&:second)
    end
  end
end