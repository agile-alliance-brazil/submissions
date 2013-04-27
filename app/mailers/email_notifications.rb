# encoding: UTF-8
class EmailNotifications < ActionMailer::Base
  default :from =>     Proc.new { "\"#{current_conference.name}\" <#{from_address}>" },
          :reply_to => Proc.new { "\"#{current_conference.name}\" <#{from_address}>" }

  def welcome(user, sent_at = Time.now)
    @user = user
    @conference_name = current_conference.name
    I18n.with_locale(@user.default_locale) do
      mail :subject => "[#{host}] #{I18n.t('email.welcome.subject')}",
           :to      => EmailNotifications.format_email(user),
           :date    => sent_at
    end
  end

  def reset_password_instructions(user, sent_at = Time.now)
    @user = user
    @conference_name = current_conference.name
    I18n.with_locale(@user.default_locale) do
      mail :subject => "[#{host}] #{I18n.t('email.password_reset.subject')}",
           :to      => EmailNotifications.format_email(user),
           :date    => sent_at
    end
  end

  def session_submitted(session, sent_at = Time.now)
    @session = session
    @conference_name = current_conference.name
    @conference = current_conference
    I18n.with_locale(@session.author.try(:default_locale)) do
      mail :subject => "[#{host}] #{I18n.t('email.session_submitted.subject', :conference_name => @conference_name)}",
           :to      => session.authors.map { |author| EmailNotifications.format_email(author) },
           :date    => sent_at
    end
  end

  def comment_submitted(session, comment, sent_at = Time.now)
    @session = session
    @comment = comment
    @conference_name = current_conference.name
    I18n.with_locale(@session.author.try(:default_locale)) do
      mail :subject => "[#{host}] #{I18n.t('email.comment_submitted.subject', :session_name => @session.title)}",
           :to      => session.authors.map { |author| EmailNotifications.format_email(author) },
           :date    => sent_at
    end
  end

  def early_review_submitted(session, sent_at = Time.now)
    @session = session
    @conference_name = current_conference.name
    I18n.with_locale(@session.author.try(:default_locale)) do
      mail :subject => "[#{host}] #{I18n.t('email.early_review_submitted.subject', :session_name => @session.title)}",
           :to      => session.authors.map { |author| EmailNotifications.format_email(author) },
           :date    => sent_at
    end
  end

  def reviewer_invitation(reviewer, sent_at = Time.now)
    @reviewer = reviewer
    @conference_name = current_conference.name
    I18n.with_locale(@reviewer.user.try(:default_locale)) do
      mail :subject  => "[#{host}] #{I18n.t('email.reviewer_invitation.subject', :conference_name => @conference_name)}",
           :to       => EmailNotifications.format_email(reviewer.user),
           :date     => sent_at
    end
  end

  def notification_of_acceptance(session, sent_at = Time.now)
    raise "Notification can't be sent before decision has been made" unless session.review_decision
    accepted = session.review_decision.accepted?
    @session = session
    @conference_name = current_conference.name
    I18n.with_locale(@session.author.try(:default_locale)) do
      subject = I18n.t("email.session_#{accepted ? 'accepted' : 'rejected'}.subject", :conference_name => @conference_name)
      mail :subject  => "[#{host}] #{subject}",
           :to       => session.authors.map { |author| EmailNotifications.format_email(author) },
           :date     => sent_at,
           :template_name => (accepted ? :notification_of_acceptance : :notification_of_rejection)
    end
  end

  private
  def self.format_email(user)
    "\"#{user.full_name}\" <#{user.email}>"
  end

  def from_address
    ActionMailer::Base.smtp_settings[:user_name]
  end

  def host
    ActionMailer::Base.default_url_options[:host]
  end

  def current_conference
    @conference ||= Conference.current
  end
end
