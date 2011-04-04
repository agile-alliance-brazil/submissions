# encoding: utf-8
Factory.define :conference do |c|
  c.sequence(:name) {|n| "Agile Brazil #{2000+n}"}
end

Factory.define :user do |u|
  u.first_name "User"
  u.sequence(:last_name) {|n| "Name#{n}"}
  u.username { |a| "#{a.first_name}.#{a.last_name}".downcase }
  u.email { |a| "#{a.username.parameterize}@example.com" }
  u.password "secret"
  u.password_confirmation "secret"
  u.phone "(11) 3322-1234"
  u.country "BR"
  u.state "SP"
  u.city "São Paulo"
  u.organization "ThoughtWorks"
  u.website_url "www.dtsato.com"
  u.bio "Some text about me..."
end

Factory.define :simple_user, :class => User do |u|
  u.first_name "User"
  u.sequence(:last_name) {|n| "Name#{n}"}
  u.username { |a| "#{a.first_name}.#{a.last_name}".downcase }
  u.email { |a| "#{a.username.parameterize}@example.com" }
  u.password "secret"
  u.password_confirmation "secret"
end

Factory.define :session_type do |t|
  t.title "session_types.tutorial.title"
  t.description "session_types.tutorial.description"
end

Factory.define :track do |t|
  t.title "tracks.engineering.title"
  t.description "tracks.engineering.description"
end

Factory.define :audience_level do |t|
  t.title "audience_levels.beginner.title"
  t.description "audience_levels.beginner.description"
end

Factory.define :session do |s|
  s.association :track
  s.association :session_type
  s.association :audience_level
  s.association :conference
  s.duration_mins 50
  s.title "Fake title"
  s.summary "Summary details of session"
  s.description "Full details of session"
  s.mechanics "Process/Mechanics"
  s.keyword_list "fake, tag"
  s.benefits "Benefits for audience"
  s.target_audience "Managers, developers, testers"
  s.association :author, :factory => :user
  s.experience "Description of author's experience on subject"
end

Factory.define :comment do |c|
  c.association :commentable, :factory => :session
  c.association :user
  c.comment "Fake comment body..."
end

Factory.define :organizer do |o|
  o.association :user
  o.association :track
  o.association :conference
end

Factory.define :reviewer do |r|
  r.association :user
  r.association :conference
end

Factory.define :preference do |p|
  p.association :reviewer
  p.association :track
  p.association :audience_level
  p.accepted true
end

Factory.define :rating do |r|
  r.title 'rating.high.title'
end

Factory.define :recommendation do |r|
  r.title 'recommendation.strong_reject.title'
end

Factory.define :review do |r|
  r.association :author_agile_xp_rating, :factory => :rating
  r.association :author_proposal_xp_rating, :factory => :rating

  r.proposal_track true
  r.proposal_level true
  r.proposal_type true
  r.proposal_duration true
  r.proposal_limit true
  r.proposal_abstract true
  
  r.association :proposal_quality_rating, :factory => :rating
  r.association :proposal_relevance_rating, :factory => :rating
  
  r.association :recommendation
  r.justification "Fake"
  
  r.association :reviewer_confidence_rating, :factory => :rating
  
  r.comments_to_organizers "Fake"
  r.comments_to_authors "Fake " * 40
  
  r.association :reviewer, :factory => :user
  r.association :session
end

Factory.define :slot do |s|
  s.association :track
  s.start_at Time.zone.local(2010, 1, 12, 9, 0, 0)
  s.end_at Time.zone.local(2010, 1, 12, 9, 45, 0)
  s.duration_mins 45
end

Factory.define :outcome do |o|
  o.title "outcomes.accept.title"
end

Factory.define :review_decision do |d|
  d.association :organizer, :factory => :user
  d.association :session
  d.association :outcome
  d.note_to_authors "Some note to the authors"
  d.published false
end

Factory.define :attendee do |a|
  a.association :conference, :factory => :conference
  a.first_name "Attendee"
  a.sequence(:last_name) {|n| "Name#{n}"}
  a.email { |e| "#{e.last_name.parameterize}@example.com" }
  a.email_confirmation { |e| "#{e.last_name.parameterize}@example.com" }
  a.phone "(11) 3322-1234"
  a.country "BR"
  a.state "SP"
  a.city "São Paulo"
  a.organization "ThoughtWorks"
  a.badge_name {|e| "The Great #{e.first_name}" }
  a.cpf "111.444.777-35"
  a.gender 'M'
  a.twitter_user {|e| "#{e.last_name.parameterize}"}
  a.address "Rua dos Bobos, 0"
  a.neighbourhood "Vila Perdida"
  a.zipcode "12345000"
  a.registration_type_value "individual"
end