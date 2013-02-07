# encoding: UTF-8

FactoryGirl.define do
  sequence(:last_name) {|n| "Name#{n}"}

  factory :user do
    first_name "User"
    last_name
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

    factory :author do
      after_build { |u| u.add_role(:author) }
    end
  end

  factory :simple_user, :class => User do
    first_name "User"
    last_name
    username { |a| "#{a.first_name}.#{a.last_name}".downcase }
    email { |a| "#{a.username.parameterize}@example.com" }
    password "secret"
    password_confirmation "secret"
  end

  factory :session_type do
    conference { Conference.current }
    title "session_types.talk.title"
    description "session_types.talk.description"
  end

  factory :track do
    conference { Conference.current }
    title "tracks.engineering.title"
    description "tracks.engineering.description"
  end

  factory :audience_level do
    conference { Conference.current }
    title "audience_levels.beginner.title"
    description "audience_levels.beginner.description"
  end

  factory :session do
    conference { Conference.current }
    track
    session_type
    audience_level
    author
    duration_mins 50
    language 'en'
    title "Fake title"
    summary "Summary details of session"
    description "Full details of session"
    mechanics "Process/Mechanics"
    keyword_list "fake, tag"
    benefits "Benefits for audience"
    target_audience "Managers, developers, testers"
    experience "Description of author's experience on subject"
  end

  factory :comment do
    association :commentable, :factory => :session
    user
    comment "Fake comment body..."
  end

  factory :organizer do
    user
    conference { Conference.current }
    track { |o| o.conference.tracks.first }
  end

  factory :reviewer do
    to_create { |instance| EmailNotifications.stubs(:send_reviewer_invitation); instance.save! }
    user
    conference { Conference.current }
  end

  factory :preference do
    reviewer
    track { |p| p.reviewer.conference.tracks.first }
    audience_level { |p| p.reviewer.conference.audience_levels.first }
    accepted true
  end

  factory :rating do
    title 'rating.high.title'
  end

  factory :recommendation do
    title 'recommendation.strong_reject.title'
  end

  trait :review do
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

    association :reviewer_confidence_rating, :factory => :rating

    comments_to_organizers "Fake"
    comments_to_authors "Fake " * 40

    association :reviewer, :factory => :user
    session
  end

  factory :early_review, :class => EarlyReview, :traits => [:review] do
    to_create { |instance| EmailNotifications.stubs(:send_early_review_submitted); instance.save! }
  end

  factory :final_review, :class => FinalReview, :traits => [:review] do
    recommendation
    justification "Fake"
  end

  factory :outcome do
    title "outcomes.accept.title"
  end

  factory :review_decision do
    association :organizer, :factory => :user
    session
    outcome
    note_to_authors "Some note to the authors"
    published false
  end

  factory :room do
    name "Room 1"
    capacity 200
    conference { Conference.current }
  end

  factory :guest_session do
    title "Guest session title"
    author "Guest session author"
    summary "Longer description and summary for guest session"
    conference { Conference.current }
    keynote true
  end

  factory :all_hands do
    title "all_hands.lunch.title"
  end

  factory :lightning_talk_group do
    lightning_talk_info {}
  end

  factory :activity do
    start_at { DateTime.now }
    end_at { |a| a.start_at + 1.hour }
    room
    association :detail, :factory => :session
  end
end