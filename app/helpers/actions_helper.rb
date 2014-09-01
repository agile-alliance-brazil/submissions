# encoding: UTF-8
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

  def sections_for(user, conference)
    sections = []

    if user_signed_in?
      sections << session_section_for(user, conference)
    end
    if user.reviewer?
      sections << reviewer_section_for(user, conference)
    end
    if user.organizer? || user.admin?
      sections << organizer_section_for(user, conference)
    end
    if user_signed_in?
      sections << user_section_for(user)
    end

    sections
  end

  def user_section_for(user)
    section = Section.new t('actions.section.user')

    if can? :read, User
      section.add t('actions.profile'), user_path(user)
    end
    if can? :update, user
      section.add t('actions.edit_profile'), edit_user_registration_path
      section.add t('actions.change_password'), edit_user_registration_path(update_password: true)
    end
    section.add 'Logout', destroy_user_session_path, { method: :delete }

    section
  end

  def session_section_for(user, conference)
    section = Section.new t('actions.section.session')

    if can? :create, Session
      section.add t('actions.submit_session'), new_session_path(conference)
    end
    if can? :read, Session
      section.add t('actions.browse_sessions'), sessions_path(conference)
      if user.sessions_for_conference(conference).count > 0
        section.add t('actions.my_sessions'), user_sessions_path(conference, user)
      end
    end
    if can? :read, Vote
      section.add t('actions.my_votes'), votes_path(conference)
    end

    section
  end

  def reviewer_section_for(user, conference)
    section = Section.new t('actions.section.review')
    if can? :read, 'reviewer_sessions'
      sessions_to_review = Session.for_reviewer(current_user, @conference).size || 0
      section.add t('actions.reviewer_sessions', count: sessions_to_review), reviewer_sessions_path(@conference)
    end
    if can? :reviewer, 'reviews_listing'
      reviews_count = user.reviews.for_conference(conference).count || 0
      section.add t('actions.reviewer_reviews', count: reviews_count), reviewer_reviews_path(@conference)
    end
    if @session.present? && (can?(:create, EarlyReview, @session) || can?(:create, FinalReview, @session))
      section.add t('actions.review_session'), new_session_review_path(@conference, @session)
    end

    section
  end

  def organizer_section_for(user, conference)
    section = Section.new t('actions.section.organize')

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
      section.add t('actions.organizer_reports'), organizer_reports_path(@conference, :format => :xls)
    end

    section
  end
end
