# frozen_string_literal: true

require 'csv'
class SessionAuthorsCSVExporter
  COLUMNS = ['Session id', 'Session title', 'Session Type', 'Author', 'Email', 'Phone'].freeze

  def initialize(sessions)
    @sessions = sessions
  end

  def to_csv
    individuals, pairs = @sessions.partition { |s| s.second_author.blank? }

    CSV.generate do |csv|
      csv << COLUMNS
      individuals.sort_by(&:session_type_id).each do |session|
        csv << row_for(session, session.author)
      end
      pairs.sort_by(&:session_type_id).each do |session|
        csv << row_for(session, session.author)
        csv << row_for(session, session.second_author)
      end
    end
  end

  private

  def row_for(session, author)
    [
      session.id,
      session.title,
      I18n.t(session.session_type.title),
      author.full_name,
      author.email,
      author.phone
    ]
  end
end
