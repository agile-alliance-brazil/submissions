class RegistrationType < ActiveRecord::Base
  belongs_to :conference
  has_many :registration_prices
  
  class << self
    def options_for_select
      all.reject{|t| t.id == 2}.map {|type| [I18n.t(type.title), type.id]}
    end
    
    def valid_values
      options_for_select.map(&:second)
    end
  end
end