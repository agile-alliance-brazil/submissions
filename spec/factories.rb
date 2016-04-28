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
      after(:build) { |u| u.add_role(:author) }
    end

    factory :voter do
      after(:build) { |u| u.add_role(:voter) }
    end
  end

  factory :simple_user, class: User do
    first_name "User"
    last_name
    username { |a| "#{a.first_name}.#{a.last_name}".downcase }
    email { |a| "#{a.username.parameterize}@example.com" }
    password "secret"
    password_confirmation "secret"
  end

  factory :session_type do
    conference { Conference.current || FactoryGirl.create(:conference) }
    valid_durations [50]
    title 'session_type.name.title'
    description 'session_type.name.description'
    translated_contents { |s|
      s.conference.supported_languages.map do |l|
        build :translated_content, language: l, title: "Session type title in #{l}", content: "This is a session type that renders with @Textile@."
      end
    }
  end

  factory :track do
    conference { Conference.current || FactoryGirl.create(:conference) }
    title 'track.name.title'
    description 'track.name.description'
    translated_contents { |t|
      t.conference.supported_languages.map do |l|
        build :translated_content, language: l, title: "Track title in #{l}", content: "This is a track that renders with @Textile@."
      end
    }
  end

  factory :audience_level do
    conference { Conference.current || FactoryGirl.create(:conference) }
    title 'audience_level.name.title'
    description 'audience_level.name.description'
    translated_contents { |a|
      a.conference.supported_languages.map do |l|
        build :translated_content, language: l, title: "Audience level title in #{l}", content: "This is an audience level that renders with @Textile@."
      end
    }
  end

  factory :comment do
    association :commentable, factory: :session
    user
    comment "Fake comment body..."
  end

  factory :organizer do
    user
    conference { Conference.current || FactoryGirl.create(:conference) }
    track do |o|
      o.conference.tracks.first ||
        FactoryGirl.create(:track, conference: o.conference)
    end
  end

  factory :reviewer do
    user
    conference { Conference.current || FactoryGirl.create(:conference) }
  end

  factory :preference do
    reviewer
    track do |p|
      p.reviewer.conference.tracks.first ||
        FactoryGirl.create(:track, conference: p.reviewer.conference)
    end
    audience_level do |p|
      p.reviewer.conference.audience_levels.first ||
        FactoryGirl.create(:audience_level, conference: p.reviewer.conference)
    end
    accepted true
  end

  factory :rating do
    title 'rating.high.title'
  end

  factory :recommendation do
    name 'strong_reject'
  end

  trait :review do
    association :author_agile_xp_rating, factory: :rating
    association :author_proposal_xp_rating, factory: :rating

    proposal_track true
    proposal_level true
    proposal_type true
    proposal_duration true
    proposal_limit true
    proposal_abstract true

    association :proposal_quality_rating, factory: :rating
    association :proposal_relevance_rating, factory: :rating

    association :reviewer_confidence_rating, factory: :rating

    comments_to_organizers "Fake"
    comments_to_authors "Fake " * 40

    association :reviewer, factory: :user
    session
  end

  factory :early_review, class: EarlyReview, traits: [:review]

  factory :final_review, class: FinalReview, traits: [:review] do
    recommendation
    justification "Fake"
  end

  factory :outcome do
    sequence(:title) {|n| "outcomes.name#{n}.title"}

    factory :accepted_outcome do
      after(:build) { |o| o.title = 'outcomes.accept.title' }
    end
    factory :rejected_outcome do
      after(:build) { |o| o.title = 'outcomes.reject.title' }
    end
  end

  factory :review_decision do
    association :organizer, factory: :user
    session { FactoryGirl.create(:session, state: 'in_review') }
    outcome
    note_to_authors "Some note to the authors"
    published false

    factory :accepted_decision

    factory :rejected_decision do
      after(:build) do |rd|
        rd.outcome = Outcome.find_by_title('outcomes.reject.title') ||
          FactoryGirl.create(:rejected_outcome)
      end
    end
  end

  factory :conference do
    sequence(:year)
    name { |c| "Conference #{c.year}" }

    location('Somewhere ST')
    call_for_papers { DateTime.now + 1.day }
    submissions_open { DateTime.now + 2.days }
    presubmissions_deadline { DateTime.now + 2.days + 1.hour }
    prereview_deadline { DateTime.now + 2.days + 12.hours }
    submissions_deadline { DateTime.now + 3.days }
    voting_deadline { DateTime.now + 3.days + 12.hours}
    review_deadline { DateTime.now + 4.days }
    author_notification { DateTime.now + 5.days }
    author_confirmation { DateTime.now + 6.days }
    start_date { DateTime.now + 1.month }
    end_date { DateTime.now + 1.month + 3.days }
    logo { File.new(Rails.root.join('spec', 'resources', 'logo-trans.png')) }
    supported_languages ['en']
    visible true
  end

  factory :page do
    conference { Conference.current || FactoryGirl.create(:conference) }
    sequence(:path) {|n| "page_#{n}"}
    title 'page.title'
    content 'page.content'
    translated_contents { |p|
      p.conference.supported_languages.map do |l|
        build :translated_content, language: l, title: p.path, content: "This is a page under path +#{p.path}+ for conference *#{p.conference.name}* that renders with @Textile@."
      end
    }
  end

  factory :vote do
    conference { Conference.current || FactoryGirl.create(:conference) }
    association :user, factory: :voter
    session
  end

  factory :review_feedback do
    conference { Conference.current || FactoryGirl.create(:conference) }
    author
    general_comments 'General comments'
  end

  factory :translated_content do
    language 'en'
    title 'Content title'
    content 'Content description'
  end
end
