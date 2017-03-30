# encoding: UTF-8
# frozen_string_literal: true

# Methods added to this helper will be available to all templates in the application.
module ActionsHelper
  class Section
    attr_reader :title, :actions

    def initialize(title)
      @title = title
      @actions = []
    end

    def add(name, link, options = nil)
      @actions << { name: name, link: link, options: options }
      self
    end
  end

  def sections_for(user, conference, safe_filter_params)
    sections = []

    sections << session_section_for(user, conference) if user_signed_in?
    if user.reviewer? || user.admin?
      sections << reviewer_section_for(user, conference, safe_filter_params)
    end
    if user.organizer? || user.admin?
      sections << organizer_section_for(user, conference)
    end
    sections << user_section_for(user) if user_signed_in?

    sections
  end

  def user_section_for(user)
    section = Section.new t('actions.section.user')

    section.add t('actions.profile'), user_path(user) if can? :read, User
    if can? :update, user
      section.add t('actions.edit_profile'), edit_user_registration_path
      section.add t('actions.change_password'), edit_user_registration_path(update_password: true)
    end
    section.add 'Logout', destroy_user_session_path, method: :delete

    section
  end

  def session_section_for(user, conference)
    section = Section.new t('actions.section.session')

    if can? :create, Session
      section.add t('actions.submit_session'), new_session_path(conference)
    end
    if can? :read, Session
      sessions_count = Session.for_conference(conference).without_state(:cancelled).count
      section.add t('actions.browse_sessions', count: sessions_count), sessions_path(conference)
      if user.sessions_for_conference(conference).count.positive?
        section.add t('actions.my_sessions'), user_sessions_path(conference, user)
      end
    end
    if can? :read, Vote
      section.add t('actions.my_votes'), votes_path(conference)
    end

    section
  end

  def reviewer_section_for(user, conference, safe_params)
    section = Section.new t('actions.section.review')
    if (conference.in_early_review_phase? ||
          conference.in_final_review_phase?) &&
       can?(:read, 'reviewer_sessions')
      sessions_to_review_count = SessionFilter.new(safe_params, params[:user_id]).apply(Session.for_reviewer(current_user, conference)).count
      section.add t('actions.reviewer_sessions', count: sessions_to_review_count), reviewer_sessions_path(conference)
    end
    if can? :reviewer, 'reviews_listing'
      reviews_count = user.reviews.for_conference(conference).count
      section.add t('actions.reviewer_reviews', count: reviews_count), reviewer_reviews_path(conference)
    end
    if @session.present? && (can?(:create, EarlyReview, @session) || can?(:create, FinalReview, @session))
      section.add t('actions.review_session'), new_session_review_path(conference, @session)
    end

    section
  end

  def filter_params
    params.permit(:session_filter)
          .permit(:track_id, :session_type_id, :audience_level_id)[:session_filter]
  end

  def organizer_section_for(_user, _conference)
    section = Section.new t('actions.section.organize')

    if can? :read, Conference
      section.add t('actions.manage_conferences'), conferences_path
    end
    if can? :read, Organizer
      section.add t('actions.manage_organizers'), organizers_path(@conference)
    end
    if can? :read, Reviewer
      section.add t('actions.manage_reviewers'), reviewers_path(@conference)
    end
    if can? :read, 'organizer_sessions'
      section.add t('actions.organizer_sessions'), organizer_sessions_path(@conference)
    end
    if can? :read, 'organizer_reports'
      section.add t('actions.organizer_reports'), organizer_reports_path(@conference, format: :xls)
    end
    if can? :read, 'accepted_sessions'
      section.add t('actions.accepted_sessions'), accepted_sessions_path(@conference, format: :csv)
    end

    section
  end
end
