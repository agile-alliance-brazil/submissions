# frozen_string_literal: true

class UserConference < ApplicationRecord
  belongs_to :user
  belongs_to :conference
  validates :user_id, :conference_id, presence: true
end
