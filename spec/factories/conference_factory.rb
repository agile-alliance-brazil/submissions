# frozen_string_literal: true
FactoryGirl.define do
  factory :conference do
    sequence(:year)
    name { |c| "Conference #{c.year}" }

    location('Somewhere ST')
    call_for_papers { 1.day.from_now }
    submissions_open { 2.days.from_now }
    presubmissions_deadline { 3.days.from_now }
    prereview_deadline { 4.days.from_now }
    submissions_deadline { 5.days.from_now }
    voting_deadline { 6.days.from_now }
    review_deadline { 7.days.from_now }
    author_notification { 8.days.from_now }
    author_confirmation { 9.days.from_now }
    start_date { 2.months.from_now }
    end_date { 3.months.from_now }
    logo { File.new(Rails.root.join('spec', 'resources', 'logo-trans.png')) }
    supported_languages ['en']
    visible true

    factory :conference_in_review_time do
      call_for_papers { 7.weeks.ago }
      submissions_open { 6.weeks.ago }
      presubmissions_deadline { 5.weeks.ago }
      prereview_deadline { 4.weeks.ago }
      submissions_deadline { 3.weeks.ago }
      voting_deadline { 2.weeks.ago }
      review_deadline { 51.days.from_now }
      author_notification { 52.days.from_now }
      author_confirmation { 53.days.from_now }
    end
  end
end
