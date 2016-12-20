# encoding: UTF-8
# frozen_string_literal: true
class Preference < ActiveRecord::Base
  belongs_to :reviewer
  belongs_to :track
  belongs_to :audience_level
  has_one :user, through: :reviewer

  validates :accepted, inclusion: { in: [true, false] }, reviewer_track: { if: :accepted? }
  validates :reviewer, existence: true
  validates :audience_level_id, presence: true, existence: true, same_conference: { target: :reviewer }, if: :accepted?
  validates :track_id, presence: true, existence: true, same_conference: { target: :reviewer }, if: :accepted?
end
