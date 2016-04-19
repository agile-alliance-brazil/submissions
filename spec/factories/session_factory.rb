FactoryGirl.define do
  factory :session do
    conference { Conference.current || FactoryGirl.create(:conference) }
    track { |s| FactoryGirl.create(:track, conference: s.conference) }
    session_type { |s| FactoryGirl.create(:session_type, conference: s.conference) }
    audience_level { |s| FactoryGirl.create(:audience_level, conference: s.conference) }
    author
    duration_mins 50
    language 'en'
    title 'Fake title'
    summary 'Summary details of session'
    description 'Full details of session'
    mechanics 'Process/Mechanics'
    keyword_list 'tags.tests,tags.learning'
    prerequisites 'Prerequisites for this sessions'
    benefits 'Benefits for audience'
    target_audience 'Managers, developers, testers'
    experience "Description of author's experience on subject"

    factory :session_cancelled do
      state :cancelled
    end
  end
end
