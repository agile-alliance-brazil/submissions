# encoding: UTF-8
class Gender
  class << self
    def options_for_select
      [[I18n.t('gender.male'), 'M'], [I18n.t('gender.female'), 'F']]
    end
    
    def valid_values
      options_for_select.map(&:second)
    end
    
    def title_for(value)
      options_for_select.find { |option| option[1] == value }.first
    end
  end
end
