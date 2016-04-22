# encoding: UTF-8
# conference = Conference.current
# sessions = Session.for_conference(conference).without_state(:cancelled)
# by_uniq_authors = lambda{|collection| collection.map{|s| [s.author, s.second_author].compact}.uniq}
# early_submissions = sessions.submitted_before(conference.presubmissions_deadline)

# report = ""
# report << "Sessões submetidas: #{sessions.count} - #{by_uniq_authors.call(sessions).count}\n"
# (9..13).each do |track_id|
#   track_sessions = sessions.for_tracks(track_id)
#   report << "#{I18n.t(Track.find(track_id).title)}: #{track_sessions.count} - #{by_uniq_authors.call(track_sessions).count}\n"
# end

# report << "\n"

# (8..10).each do |session_type_id|
#   type_sessions = sessions.select{|s| s.session_type_id == session_type_id}
#   session_type = SessionType.find(session_type_id)
#   report << "#{I18n.t(session_type.title)}: #{type_sessions.count} - #{by_uniq_authors.call(type_sessions).count}\n"
# end

conference = Conference.current
sessions = Session.for_conference(conference).without_state(:cancelled)
review_count = FinalReview.for_conference(conference).count
session_count = sessions.count * 3
grouped = sessions.group_by(&:final_reviews_count)
reviewers = Reviewer.for_conference(conference).accepted
non_active = reviewers.select { |reviewer| reviewer.user.reviews.for_conference(conference).select {|r| r.type == 'FinalReview'}.count == 0}

report = ""
report << "#{review_count} avaliações de #{session_count} necessárias (~ #{'%.2f' % (review_count * 100.0 / session_count)}%)\n"
grouped.sort {|group1, group2| group1.first <=> group2.first}.each do |key, value|
	report << "#{value.size} sessões com #{key} avaliações\n"
end
report << "\n"
report << "#{non_active.count} avaliadores não começaram as avaliações"
report << "\n"
report << "Faltam #{conference.review_deadline.to_date - Date.today} dias para o fim das avaliações\n"
puts report

active_reviewers = reviewers.reject { |reviewer| reviewer.user.reviews.for_conference(conference).select {|r| r.type == 'FinalReview'}.count == 0}
puts active_reviewers.map(&:user).map(&:full_name).sort.join("\n")
