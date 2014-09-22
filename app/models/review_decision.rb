# encoding: UTF-8
class ReviewDecision < ActiveRecord::Base
  attr_accessible :organizer_id, :session_id, :outcome_id, :note_to_authors
  attr_trimmed    :note_to_authors

  belongs_to :session
  belongs_to :outcome
  belongs_to :organizer, class_name: "User"
  
  validates :organizer_id, presence: true, existence: true
  validates :session_id, presence: true, existence: true
  validates :outcome_id, presence: true, existence: true, allow_blank: true
  validates :note_to_authors, presence: true
  validates :session_id, session_acceptance: true
  
  after_save do
    case outcome
    when Outcome.find_by_title('outcomes.accept.title')
      session.tentatively_accept unless session.pending_confirmation?
    when Outcome.find_by_title('outcomes.reject.title')
      session.reject unless session.rejected?
    end
  end

  scope :for_conference, lambda { |c| joins(:session).where(sessions: {conference_id: c.id}) }
  scope :for_tracks, lambda { |track_ids| joins(:session).where(sessions: {track_id: track_ids}) }
  scope :accepted, lambda { where(outcome_id: Outcome.find_by_title('outcomes.accept.title').id) }
  scope :confirmed, lambda { joins(:session).where(sessions: {state: ['accepted', 'rejected']}) }
  
  def accepted?
    outcome == Outcome.find_by_title('outcomes.accept.title')
  end

  def rejected?
    outcome == Outcome.find_by_title('outcomes.reject.title')
  end
end
