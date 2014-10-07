# encoding: UTF-8
class Recommendation < ActiveRecord::Base
  validates :name, presence: true
  
  has_many :reviews

  def self.all_names
    %W(strong_accept weak_accept weak_reject strong_reject)
  end

  def self.title_for(name)
    "recommendation.#{name}.title"
  end

  def title
    Recommendation.title_for(self.name)
  end

  def respond_to_missing?(method_sym, include_private = false)
    is_name_check_method?(method_sym) || super
  end

  def method_missing(method_sym, *arguments, &block)
    if is_name_check_method?(method_sym)
      name_matches(method_sym)
    else
      super
    end
  end

  private

  def name_matches(method_sym)
    name_to_check = method_sym.to_s.gsub(/\?$/,'')
    self.name == "#{name_to_check}"
  end

  def is_name_check_method?(method_sym)
    method_sym.to_s.ends_with?('?') &&
      Recommendation.all_names.
        map{|name| "#{name}?"}.
        include?(method_sym.to_s)
  end
end
