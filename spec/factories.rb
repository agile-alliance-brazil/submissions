Factory.define :user do |u|
  u.first_name "Danilo"
  u.last_name "Sato"
  u.username { |a| "#{a.first_name}.#{a.last_name}".downcase }
  u.email { |a| "#{a.username}@example.com" }
  u.password "secret"
  u.password_confirmation "secret"
  u.phone "(11) 3322-1234"
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
  t.title "track.engineering.title"
  t.description "track.engineering.description"
end

Factory.define :session do |s|
  s.title "Fake title"
  s.summary "Summary details of session"
  s.description "Full details of session"
  s.mechanics "Process/Mechanics"
  s.benefits "Benefits for audience"
  s.target_audience "Managers, developers, testers"
  s.association :author, :factory => :user
  s.experience "Description of author's experience on subject"
end