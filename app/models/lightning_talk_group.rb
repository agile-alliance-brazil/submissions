# encoding: UTF-8
class LightningTalkGroup < ActiveRecord::Base
  attr_accessible :lightning_talk_info
  serialize :lightning_talk_info, Array

  def lightning_talks
    lightning_talk_info.sort_by { |info| info[:order] }.map do |info|
      info[:type].constantize.find(info[:id]) rescue nil
    end.compact
  end

  def author_names
    lightning_talks.map do |lightning_talk|
      case lightning_talk
      when Session then lightning_talk.authors.map(&:full_name)
      when GuestSession then lightning_talk.author
      end
    end.flatten.join(", ")
  end
end
