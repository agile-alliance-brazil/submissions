# encoding: UTF-8
namespace :request do

  desc "Requests feedback about reviews to all authors"
  task :review_feedback => [:environment] do
    ReviewFeedbackRequester.new.send
  end

end
