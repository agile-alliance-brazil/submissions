# frozen_string_literal: true

module Privileges
  class Organizer < Privileges::Base
    def privileges
      can(:manage, ::Reviewer, conference: { visible: true })
      can(:read, 'organizer_sessions') do
        @conference.visible?
      end
      can(:read, 'organizer_reports') do
        @conference.visible?
      end
      can(:read, 'accepted_sessions') do
        @conference.visible?
      end
      can(:read, 'reviews_listing') do
        @conference.visible?
      end
      can(:index, ReviewDecision)
      can(:cancel, Session) do |session|
        session.can_cancel? && @user.organized_tracks(@conference).include?(session.track)
      end
      can(:show, Review)
      can(:show, FinalReview)
      can(:show, EarlyReview)
      can!(:organizer, [EarlyReview, FinalReview]) do
        @user.organized_tracks(@conference).include?(@session.try(:track))
      end
      can!(:create, ReviewDecision) do |session|
        session.try(:in_review?) &&
          @user.organized_tracks(@conference).include?(session.track) &&
          Time.zone.now > @conference.review_deadline
      end
      can!(:update, ReviewDecision) do |session|
        !session.try(:author_agreement) &&
          (session.try(:pending_confirmation?) || session.try(:rejected?)) &&
          @user.organized_tracks(@conference).include?(session.track) &&
          Time.zone.now > @conference.review_deadline
      end
    end
  end
end
