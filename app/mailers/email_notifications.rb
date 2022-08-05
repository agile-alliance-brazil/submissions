# frozen_string_literal: true

class EmailNotifications < ActionMailer::Base
  PROGRAM_COMMITTEE_EMAIL = 'programa@agilebrazil.com'
  default from: proc { "\"#{conference.name}\" <#{from_address}>" },
          reply_to: proc { "\"#{conference.name}\" <#{from_address}>" }

  def welcome(user, sent_at = Time.now)
    @user = user
    @conference_name = conference.name
    I18n.with_locale(@user.default_locale) do
      mail subject: "[#{host}] #{I18n.t('email.welcome.subject')}",
           to: EmailNotifications.format_email(user),
           date: sent_at
    end
  end

  def reset_password_instructions(user, token, sent_at = Time.now, _opts = {})
    @user = user
    @token = token
    @conference_name = conference.name
    I18n.with_locale(@user.default_locale) do
      mail subject: "[#{host}] #{I18n.t('email.password_reset.subject')}",
           to: EmailNotifications.format_email(user),
           date: sent_at
    end
  end

  def session_submitted(session, sent_at = Time.now)
    @session = session
    @conference_name = conference.name
    I18n.with_locale(@session.author.try(:default_locale)) do
      mail subject: "[#{host}] #{I18n.t('email.session_submitted.subject', conference_name: @conference_name)}",
           to: session.authors.map { |author| EmailNotifications.format_email(author) },
           date: sent_at
    end
  end

  def session_withdrawn(session, sent_at = Time.now)
    @session = session
    @conference_name = session.conference.name
    mail subject: "[#{host}] #{I18n.t('email.session_withdrawn.subject', session_name: @session.title)}",
         to: PROGRAM_COMMITTEE_EMAIL,
         date: sent_at
  end

  def comment_submitted(session, comment, sent_at = Time.now)
    @session = session
    @comment = comment
    @conference_name = conference.name
    authors = session.authors.map { |author| EmailNotifications.format_email(author) }
    commenters = session.comments.map { |other_comment| EmailNotifications.format_email(other_comment.user) }
    I18n.with_locale(@session.author.try(:default_locale)) do
      mail subject: "[#{host}] #{I18n.t('email.comment_submitted.subject', session_name: @session.title)}",
           to: 'no-reply@agilebrazil.com',
           bcc: authors + commenters,
           date: sent_at
    end
  end

  def early_review_submitted(session, sent_at = Time.now)
    @session = session
    @conference_name = conference.name
    I18n.with_locale(@session.author.try(:default_locale)) do
      mail subject: "[#{host}] #{I18n.t('email.early_review_submitted.subject', session_name: @session.title)}",
           to: session.authors.map { |author| EmailNotifications.format_email(author) },
           date: sent_at
    end
  end

  def reviewer_invitation(reviewer, sent_at = Time.now)
    @reviewer = reviewer
    @conference_name = conference.name
    I18n.with_locale(@reviewer.user.try(:default_locale)) do
      mail subject: "[#{host}] #{I18n.t('email.reviewer_invitation.subject', conference_name: @conference_name)}",
           to: EmailNotifications.format_email(reviewer.user),
           date: sent_at
    end
  end

  def notification_of_acceptance(session, sent_at = Time.now)
    decision = session.review_decision
    raise "Notification can't be sent before decision has been made" unless decision

    accepted = decision.accepted?
    template_name = decision.outcome.title.gsub(/^outcomes\.([^.]+)\.title$/, 'notification_of_\1').to_sym
    @session = session
    @conference_name = conference.name
    @conference_location = conference.location
    I18n.with_locale(@session.author.try(:default_locale)) do
      subject = I18n.t("email.session_#{accepted ? 'accepted' : 'rejected'}.subject", conference_name: @conference_name)
      mail subject: "[#{host}] #{subject}",
           to: session.authors.map { |author| EmailNotifications.format_email(author) },
           date: sent_at,
           template_name: template_name
    end
  end

  def review_feedback_request(author, sent_at = Time.now)
    @conference_name = conference.name
    @author = author
    I18n.with_locale(author.try(:default_locale)) do
      subject = I18n.t('email.review_feedback.subject', conference_name: @conference_name)
      mail subject: "[#{host}] #{subject}",
           to: EmailNotifications.format_email(author),
           date: sent_at,
           template_name: :review_feedback_request
    end
  end

  def self.format_email(user)
    "\"#{user.full_name}\" <#{user.email}>"
  end

  private

  def from_address
    APP_CONFIG[:sender_address]
  end

  def host
    ActionMailer::Base.default_url_options[:host]
  end

  def conference
    @conference ||= Conference.current
  end
end
