# encoding: UTF-8

FactoryGirl.define do
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
    conference { Conference.current }
    title "session_types.tutorial.title"
    description "session_types.tutorial.description"
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
    association :track
    association :session_type
    association :audience_level
    conference { Conference.current }
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
    conference { Conference.current }
  end

  factory :reviewer do
    association :user
    conference { Conference.current }
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

  factory :final_review, :class => FinalReview do
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
end