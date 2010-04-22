class ReviewDecision < ActiveRecord::Base
  attr_accessible :organizer_id, :session_id, :outcome_id, :note_to_authors
  attr_trimmed    :note_to_authors

  belongs_to :session
  belongs_to :outcome
  belongs_to :organizer, :class_name => "User"
  
  validates_presence_of :organizer_id, :session_id, :outcome_id, :note_to_authors
  validates_existence_of :organizer, :session, :outcome, :message => :existence
  
  validates_each :session_id do |record, attr, value|
    case record.outcome
    when Outcome.find_by_title('outcomes.accept.title')
      record.errors.add(attr, :cant_accept) unless record.session.try(:can_tentatively_accept?)
    when Outcome.find_by_title('outcomes.reject.title')
      record.errors.add(attr, :cant_reject) unless record.session.try(:can_reject?)
    end
  end
  
  def after_create
    case outcome
    when Outcome.find_by_title('outcomes.accept.title')
      session.tentatively_accept
    when Outcome.find_by_title('outcomes.reject.title')
      session.reject
    end
  end
end