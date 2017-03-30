# encoding: UTF-8
# frozen_string_literal: true

namespace :request do
  desc 'Requests feedback about reviews to all authors'
  task review_feedback: [:environment] do
    ReviewFeedbackRequester.new.send
  end
end
