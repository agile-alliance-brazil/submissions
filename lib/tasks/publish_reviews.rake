# encoding: UTF-8
namespace :publish do

  desc "Publish session reviews and decisions for all authors"
  task reviews: [:environment] do
    ReviewPublisher.new.publish
  end
  
end
