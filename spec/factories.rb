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

Factory.define :track do |t|
  t.title "Engineering"
  t.description "Best track eva!"
end