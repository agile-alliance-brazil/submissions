# encoding: UTF-8
SessionType.seed do |session_type|
  session_type.id = 1
  session_type.title = 'session_types.tutorial.title'
  session_type.description = 'session_types.tutorial.description'
end

SessionType.seed do |session_type|
  session_type.id = 2
  session_type.title = 'session_types.workshop.title'
  session_type.description = 'session_types.workshop.description'
end

SessionType.seed do |session_type|
  session_type.id = 3
  session_type.title = 'session_types.talk.title'
  session_type.description = 'session_types.talk.description'
end

SessionType.seed do |session_type|
  session_type.id = 4
  session_type.title = 'session_types.lightning_talk.title'
  session_type.description = 'session_types.lightning_talk.description'
end
