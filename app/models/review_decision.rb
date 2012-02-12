# encoding: UTF-8
class ReviewDecision < ActiveRecord::Base
  attr_accessible :organizer_id, :session_id, :outcome_id, :note_to_authors
  attr_trimmed    :note_to_authors

  belongs_to :session
  belongs_to :outcome
  belongs_to :organizer, :class_name => "User"
  
  validates_presence_of :organizer_id, :session_id, :outcome_id, :note_to_authors
  validates_existence_of :organizer, :session, :outcome
  
  validates_each :session_id do |record, attr, value|
    case record.outcome
    when Outcome.find_by_title('outcomes.accept.title')
      record.errors.add(attr, :cant_accept) unless record.session.pending_confirmation? || record.session.try(:can_tentatively_accept?)
    when Outcome.find_by_title('outcomes.reject.title')
      record.errors.add(attr, :cant_reject) unless record.session.rejected? || record.session.try(:can_reject?)
    end
  end
  
  after_save do
    case outcome
    when Outcome.find_by_title('outcomes.accept.title')
      session.tentatively_accept unless session.pending_confirmation?
    when Outcome.find_by_title('outcomes.reject.title')
      session.reject unless session.rejected?
    end
  end

  scope :for_conference, lambda { |c| joins(:session).where('sessions.conference_id = ?', c.id) }
  
  scope :for_tracks, lambda { |track_ids| joins(:session).where('sessions.track_id IN(?)', track_ids) }
  
  scope :accepted, where('outcome_id = ?', Outcome.find_by_title('outcomes.accept.title').id)
  
  scope :confirmed, joins(:session).where('sessions.state IN (?)', ['accepted', 'rejected'])
  
  def accepted?
    outcome == Outcome.find_by_title('outcomes.accept.title')
  end

  def rejected?
    outcome == Outcome.find_by_title('outcomes.reject.title')
  end
end
