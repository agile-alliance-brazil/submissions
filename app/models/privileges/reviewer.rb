# frozen_string_literal: true

module Privileges
  class Reviewer < Privileges::Base
    def privileges
      can(:read, 'reviewer_sessions') do
        @conference.visible?
      end
      can(%i[show edit update], Review, reviewer_id: @user.id)
      can(%i[show edit update], FinalReview, reviewer_id: @user.id)
      can(%i[show edit update], EarlyReview, reviewer_id: @user.id)

      can!(:create, EarlyReview) do |session|
        Session.for_reviewer(@user, @conference).include?(session) && @conference.in_early_review_phase?
      end

      can!(:create, FinalReview) do |session|
        Session.for_reviewer(@user, @conference).include?(session) && @conference.in_final_review_phase?
      end

      can(%i[read reviewer], 'reviews_listing') do
        @conference.visible?
      end
    end
  end
end
