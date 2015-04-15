# encoding: UTF-8
SessionType.seed do |session_type|
  session_type.id = 1
  session_type.conference_id = 1
  session_type.title = 'session_types.tutorial.title'
  session_type.description = 'session_types.tutorial.description'
  session_type.valid_durations = [45, 90]
end

SessionType.seed do |session_type|
  session_type.id = 2
  session_type.conference_id = 1
  session_type.title = 'session_types.workshop.title'
  session_type.description = 'session_types.workshop.description'
  session_type.valid_durations = [45, 90]
end

SessionType.seed do |session_type|
  session_type.id = 3
  session_type.conference_id = 1
  session_type.title = 'session_types.talk.title'
  session_type.description = 'session_types.talk.description'
  session_type.valid_durations = [45, 90]
end

SessionType.seed do |session_type|
  session_type.id = 4
  session_type.conference_id = 2
  session_type.title = 'session_types.tutorial.title'
  session_type.description = 'session_types.tutorial.description'
  session_type.valid_durations = [50, 110]
end

SessionType.seed do |session_type|
  session_type.id = 5
  session_type.conference_id = 2
  session_type.title = 'session_types.workshop.title'
  session_type.description = 'session_types.workshop.description'
  session_type.valid_durations = [50, 110]
end

SessionType.seed do |session_type|
  session_type.id = 6
  session_type.conference_id = 2
  session_type.title = 'session_types.talk.title'
  session_type.description = 'session_types.talk.description'
  session_type.valid_durations = [50, 110]
end

SessionType.seed do |session_type|
  session_type.id = 7
  session_type.conference_id = 2
  session_type.title = 'session_types.lightning_talk.title'
  session_type.description = 'session_types.lightning_talk.description'
  session_type.valid_durations = [10]
end

SessionType.seed do |session_type|
  session_type.id = 8
  session_type.conference_id = 3
  session_type.title = 'session_types.talk.title'
  session_type.description = 'session_types.talk.description'
  session_type.valid_durations = [50]
end

SessionType.seed do |session_type|
  session_type.id = 9
  session_type.conference_id = 3
  session_type.title = 'session_types.hands_on.title'
  session_type.description = 'session_types.hands_on.description'
  session_type.valid_durations = [110]
end

SessionType.seed do |session_type|
  session_type.id = 10
  session_type.conference_id = 3
  session_type.title = 'session_types.lightning_talk.title'
  session_type.description = 'session_types.lightning_talk.description'
  session_type.valid_durations = [10]
end

SessionType.seed do |session_type|
  session_type.id = 11
  session_type.conference_id = 4
  session_type.title = 'session_types.talk.title'
  session_type.description = 'session_types.talk.description'
  session_type.valid_durations = [50]
end

SessionType.seed do |session_type|
  session_type.id = 12
  session_type.conference_id = 4
  session_type.title = 'session_types.hands_on.title'
  session_type.description = 'session_types.hands_on.description'
  session_type.valid_durations = [50, 80]
end

SessionType.seed do |session_type|
  session_type.id = 13
  session_type.conference_id = 4
  session_type.title = 'session_types.experience_report.title'
  session_type.description = 'session_types.experience_report.description'
  session_type.valid_durations = [25]
end

## 2014
SessionType.seed do |session_type|
  session_type.id = 14
  session_type.conference_id = 5
  session_type.title = 'session_types.traditional_talk.title'
  session_type.description = 'session_types.traditional_talk.description'
  session_type.valid_durations = [50]
end

SessionType.seed do |session_type|
  session_type.id = 15
  session_type.conference_id = 5
  session_type.title = 'session_types.duel.title'
  session_type.description = 'session_types.duel.description'
  session_type.valid_durations = [50]
end

SessionType.seed do |session_type|
  session_type.id = 16
  session_type.conference_id = 5
  session_type.title = 'session_types.hands_on.title'
  session_type.description = 'session_types.hands_on.description'
  session_type.valid_durations = [80]
end

SessionType.seed do |session_type|
  session_type.id = 17
  session_type.conference_id = 5
  session_type.title = 'session_types.experience_report.title'
  session_type.description = 'session_types.experience_report.description'
  session_type.valid_durations = [25]
end

## 2015
### Talk 
SessionType.seed do |session_type|
  session_type.id = 18
  session_type.conference_id = 6
  session_type.title = 'session_types.traditional_talk.title'
  session_type.description = 'session_types.traditional_talk.description'
  session_type.valid_durations = [50]
end

### Duel  
SessionType.seed do |session_type|
  session_type.id = 19
  session_type.conference_id = 6
  session_type.title = 'session_types.duel.title'
  session_type.description = 'session_types.duel.description'
  session_type.valid_durations = [50]
end

### Hands On 
SessionType.seed do |session_type|
  session_type.id = 20
  session_type.conference_id = 6
  session_type.title = 'session_types.hands_on.title'
  session_type.description = 'session_types.hands_on.description'
  session_type.valid_durations = [80]
end

### Experience Report 
SessionType.seed do |session_type|
  session_type.id = 21
  session_type.conference_id = 6
  session_type.title = 'session_types.experience_report.title'
  session_type.description = 'session_types.experience_report.description'
  session_type.valid_durations = [15]
end

### Are you sure of it? 
SessionType.seed do |session_type|
  session_type.id = 22
  session_type.conference_id = 6
  session_type.title = 'session_types.are_you_sure_of_it.title'
  session_type.description = 'session_types.are_you_sure_of_it.description'
  session_type.valid_durations = [50]
end
