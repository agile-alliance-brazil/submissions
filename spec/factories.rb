# encoding: UTF-8

FactoryGirl.define do
  factory :conference do
    sequence(:name) {|n| "Agile Brazil #{2000+n}"}
  end

  factory :user do
    first_name "User"
    sequence(:last_name) {|n| "Name#{n}"}
    username { |a| "#{a.first_name}.#{a.last_name}".downcase }
    email { |a| "#{a.username.parameterize}@example.com" }
    password "secret"
    password_confirmation "secret"
    phone "(11) 3322-1234"
    country "BR"
    state "SP"
    city "São Paulo"
    organization "ThoughtWorks"
    website_url "www.dtsato.com"
    bio "Some text about me..."
  end

  factory :simple_user, :class => User do
    first_name "User"
    sequence(:last_name) {|n| "Name#{n}"}
    username { |a| "#{a.first_name}.#{a.last_name}".downcase }
    email { |a| "#{a.username.parameterize}@example.com" }
    password "secret"
    password_confirmation "secret"
  end

  factory :session_type do
    title "session_types.tutorial.title"
    description "session_types.tutorial.description"
  end

  factory :track do
    title "tracks.engineering.title"
    description "tracks.engineering.description"
  end

  factory :audience_level do
    title "audience_levels.beginner.title"
    description "audience_levels.beginner.description"
  end

  factory :session do
    association :track
    association :session_type
    association :audience_level
    association :conference
    duration_mins 50
    title "Fake title"
    summary "Summary details of session"
    description "Full details of session"
    mechanics "Process/Mechanics"
    keyword_list "fake, tag"
    benefits "Benefits for audience"
    target_audience "Managers, developers, testers"
    association :author, :factory => :user
    experience "Description of author's experience on subject"
  end

  factory :comment do
    association :commentable, :factory => :session
    association :user
    comment "Fake comment body..."
  end

  factory :organizer do
    association :user
    association :track
    association :conference
  end

  factory :reviewer do
    association :user
    association :conference
  end

  factory :preference do
    association :reviewer
    association :track
    association :audience_level
    accepted true
  end

  factory :rating do
    title 'rating.high.title'
  end

  factory :recommendation do
    title 'recommendation.strong_reject.title'
  end

  factory :review do
    association :author_agile_xp_rating, :factory => :rating
    association :author_proposal_xp_rating, :factory => :rating
    
    proposal_track true
    proposal_level true
    proposal_type true
    proposal_duration true
    proposal_limit true
    proposal_abstract true
    
    association :proposal_quality_rating, :factory => :rating
    association :proposal_relevance_rating, :factory => :rating
    
    association :recommendation
    justification "Fake"
    
    association :reviewer_confidence_rating, :factory => :rating
    
    comments_to_organizers "Fake"
    comments_to_authors "Fake " * 40
    
    association :reviewer, :factory => :user
    association :session
  end

  factory :slot do
    association :track
    start_at Time.zone.local(2010, 1, 12, 9, 0, 0)
    end_at Time.zone.local(2010, 1, 12, 9, 45, 0)
    duration_mins 45
  end

  factory :outcome do
    title "outcomes.accept.title"
  end

  factory :review_decision do
    association :organizer, :factory => :user
    association :session
    association :outcome
    note_to_authors "Some note to the authors"
    published false
  end

  factory :attendee do
    association :conference
    registration_type { RegistrationType.find_by_title('registration_type.individual') }
    
    first_name "Attendee"
    sequence(:last_name) {|n| "Name#{n}"}
    email { |e| "#{e.last_name.parameterize}@example.com" }
    email_confirmation { |e| "#{e.last_name.parameterize}@example.com" }
    phone "(11) 3322-1234"
    country "BR"
    state "SP"
    city "São Paulo"
    organization "ThoughtWorks"
    badge_name {|e| "The Great #{e.first_name}" }
    cpf "111.444.777-35"
    gender 'M'
    twitter_user {|e| "#{e.last_name.parameterize}"}
    address "Rua dos Bobos, 0"
    neighbourhood "Vila Perdida"
    zipcode "12345000"
  end

  factory :course do
    association :conference
    name "Course"
    full_name "That big course of ours"
    combine false
  end

  factory :course_attendance do
    association :course
    association :attendee
  end

  factory :registration_group do
    name "Big Corp"
    contact_name "Contact Name"
    contact_email { |e| "contact@#{e.name.parameterize}.com" }
    contact_email_confirmation { |e| "contact@#{e.name.parameterize}.com" }
    phone "(11) 3322-1234"
    fax "(11) 4422-1234"
    country "BR"
    state "SP"
    city "São Paulo"
    cnpj "69.103.604/0001-60"
    state_inscription "110.042.490.114"
    municipal_inscription "9999999"
    address "Rua dos Bobos, 0"
    neighbourhood "Vila Perdida"
    zipcode "12345000"
    total_attendees 5
  end

  factory :payment_notification do
    params { {:some => 'params'} }
    status "Completed"
    transaction_id "9JU83038HS278211W"
    association :invoicer, :factory => :attendee
  end
end