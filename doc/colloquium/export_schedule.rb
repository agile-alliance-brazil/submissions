# encoding: UTF-8

require 'faster_csv'

def accepted_sessions
  Session.for_conference(Conference.current).with_state(:accepted)
end

def session_fields(session)
  [session.title, session.summary]
end

ROOM_CAPACITY = {
  Track.find_by_title('tracks.general_interest.title') => 160,
  Track.find_by_title('tracks.management.title') => 170,
  Track.find_by_title('tracks.engineering.title') => 170,
  Track.find_by_title('tracks.experience_reports.title') => 160
}

def room_fields(track)
  ["Fábrica de Negócios", "2º Andar", I18n.t(track.title), ROOM_CAPACITY[track]]
end

def schedule
  @schedule ||= {}.tap do |sch|
    FasterCSV.foreach('sessions.csv', :headers => true) do |line|
      sch[line[0].to_i] = {:start_at => DateTime.parse(line[1]), :end_at => DateTime.parse(line[2])}
    end
  end
end

def schedule_fields(session)
  scheduled = schedule[session.id]
  if scheduled
    [scheduled[:start_at].strftime("%m/%d/%y %H:%M"), scheduled[:end_at].strftime("%m/%d/%y %H:%M")]
  else
    [nil, nil]
  end
end

def track_fields(track)
  [I18n.t(track.title), nil]
end

def author_fields(user)
  [user.full_name, nil, nil, user.bio]
end

FasterCSV.open("agile_brazil_schedule.csv", "w") do |csv|
  csv << ["Title","Description","Tower","Floor","Room","Room Capacity","Start Time(MM/DD/YY HH:MM)","End Time(MM/DD/YY HH:MM)","Track","Track Description","Presenter1 Name","Presenter1 Email","Presenter1 Designation","Presenter1 Experience","Presenter2 Name","Presenter2 Email","Presenter2 Designation","Presenter2 Experience","Presenter3 Name","Presenter3 Email","Presenter3 Designation","Presenter3 Experience"]
  accepted_sessions.each do |session|
    fields = session_fields(session) + room_fields(session.track) + schedule_fields(session) + track_fields(session.track) + author_fields(session.author)
    fields += author_fields(session.second_author) if session.second_author
    
    csv << fields
  end
end
