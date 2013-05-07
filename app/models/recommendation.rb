# encoding: UTF-8
class Recommendation < ActiveRecord::Base
  validates :title, :presence => true
  
  has_many :reviews

  def self.all_titles
    self.select(:title).uniq.map do |recommendation|
      recommendation.title.match(/recommendation\.(\w+)\.title/)[1]
    end
  end

  all_titles.each do |type|
    define_method("#{type}?") do                   # def strong_accept?
      self.title == "recommendation.#{type}.title" #   self.title == 'recommendation.strong_accept.title'
    end                                            # end
  end
end
