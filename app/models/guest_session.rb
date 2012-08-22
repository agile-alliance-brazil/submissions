# encoding: UTF-8
class GuestSession < ActiveRecord::Base
  attr_accessible :title, :summary, :author, :conference_id, :keynote

  belongs_to :conference
end
