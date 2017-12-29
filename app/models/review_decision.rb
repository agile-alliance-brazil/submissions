# frozen_string_literal: true

class ReviewDecision < ApplicationRecord
  attr_trimmed :note_to_authors

  belongs_to :session
  belongs_to :outcome
  belongs_to :organizer, class_name: 'User', inverse_of: :review_decisions

  validates :organizer_id, presence: true, existence: true
  validates :session_id, presence: true, existence: true
  validates :outcome_id, presence: true, existence: true
  validates :note_to_authors, presence: true
  validates :session_id, session_acceptance: true

  after_save do
    case outcome.title
    when 'outcomes.accept.title'
      session.tentatively_accept unless session.pending_confirmation?
    when 'outcomes.reject.title'
      session.reject unless session.rejected?
    when 'outcomes.backup.title'
      session.reject unless session.rejected?
    end
  end

  scope(:for_conference, ->(c) { joins(:session).where(sessions: { conference_id: c.id }) })
  scope(:for_tracks, ->(track_ids) { joins(:session).where(sessions: { track_id: track_ids }) })
  scope(:accepted, -> { where(outcome_id: Outcome.find_by(title: 'outcomes.accept.title').id) })
  scope(:confirmed, -> { joins(:session).where(sessions: { state: %w[accepted rejected] }) })

  def accepted?
    outcome.title == 'outcomes.accept.title'
  end

  def rejected?
    outcome.title == 'outcomes.reject.title' ||
      outcome == 'outcomes.backup.title'
  end
end
