class ReviewDecision < ActiveRecord::Base
  attr_accessible :session_id, :outcome_id, :note_to_authors
  attr_trimmed    :note_to_authors

  belongs_to :session
  belongs_to :outcome
  
  validates_presence_of :session_id, :outcome_id, :note_to_authors
  validates_existence_of :session, :outcome, :message => :existence
end