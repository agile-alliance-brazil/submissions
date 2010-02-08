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
  s.duration_mins 45
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