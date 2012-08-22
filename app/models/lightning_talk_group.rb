# encoding: UTF-8
class LightningTalkGroup < ActiveRecord::Base
  attr_accessible :lightning_talk_ids
  serialize :lightning_talk_ids, Array

  def lightning_talks
    Session.where(:id => lightning_talk_ids).all
  end
end
