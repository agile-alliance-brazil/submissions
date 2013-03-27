# encoding: utf-8
class Privileges::Reviewer < Privileges::Base
  def privileges
    can(:read, 'reviewer_sessions')
    can(:show, Review, :reviewer_id => @user.id)
    can(:show, FinalReview, :reviewer_id => @user.id)
    can(:show, EarlyReview, :reviewer_id => @user.id)
    can!(:create, EarlyReview) do |session|
      Session.for_reviewer(@user, @conference).include?(session) && @conference.in_early_review_phase?
    end
    can!(:create, FinalReview) do |session|
      Session.for_reviewer(@user, @conference).include?(session) && @conference.in_final_review_phase?
    end
    can([:read, :reviewer], 'reviews_listing')
  end
end
