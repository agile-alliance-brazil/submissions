# encoding: UTF-8
class Recommendation < ActiveRecord::Base
  validates :title, presence: true
  
  has_many :reviews

  def self.all_titles
    %W(strong_accept weak_accept weak_reject strong_reject)
  end

  all_titles.each do |type|
    define_method("#{type}?") do                   # def strong_accept?
      self.title == "recommendation.#{type}.title" #   self.title == 'recommendation.strong_accept.title'
    end                                            # end
  end
end
