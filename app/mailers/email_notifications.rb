# encoding: UTF-8
class EmailNotifications < ActionMailer::Base

  def self.send_welcome(user, sent_at = Time.now)
    I18n.with_locale(user.default_locale) do
      welcome(user, sent_at).deliver
    end
  end

  def welcome(user, sent_at = Time.now)
    @user = user
    @conference_name = current_conference.name
    mail :subject => "[#{host}] #{I18n.t('email.welcome.subject')}",
         :to      => "\"#{user.full_name}\" <#{user.email}>",
         :from     => "\"#{@conference_name}\" <#{from_address}>",
         :reply_to => "\"#{@conference_name}\" <#{from_address}>",
         :date => sent_at
  end

  def self.send_reset_password_instructions(user, sent_at = Time.now)
    I18n.with_locale(user.default_locale) do
      reset_password_instructions(user, sent_at).deliver
    end
  end

  def reset_password_instructions(user, sent_at = Time.now)
    @user = user
    @conference_name = current_conference.name
    mail :subject => "[#{host}] #{I18n.t('email.password_reset.subject')}",
         :to      => "\"#{user.full_name}\" <#{user.email}>",
         :from     => "\"#{@conference_name}\" <#{from_address}>",
         :reply_to => "\"#{@conference_name}\" <#{from_address}>",
         :date => sent_at
  end

  def self.send_session_submitted(session, sent_at = Time.now)
    I18n.with_locale(session.author.try(:default_locale)) do
      session_submitted(session, sent_at).deliver
    end
  end

  def session_submitted(session, sent_at = Time.now)
    @session = session
    @conference_name = current_conference.name
    @conference = current_conference
    mail :subject => "[#{host}] #{I18n.t('email.session_submitted.subject', :conference_name => @conference_name)}",
         :to      => session.authors.map { |author| "\"#{author.full_name}\" <#{author.email}>" },
         :from     => "\"#{@conference_name}\" <#{from_address}>",
         :reply_to => "\"#{@conference_name}\" <#{from_address}>",
         :date => sent_at
  end

  def self.send_comment_submitted(session, comment, sent_at = Time.now)
    I18n.with_locale(session.author.try(:default_locale)) do
      comment_submitted(session, comment, sent_at).deliver
    end
  end

  def comment_submitted(session, comment, sent_at = Time.now)
    @session = session
    @comment = comment
    @conference_name = current_conference.name
    mail :subject => "[#{host}] #{I18n.t('email.comment_submitted.subject', :session_name => @session.title)}",
         :to      => session.authors.map { |author| "\"#{author.full_name}\" <#{author.email}>" },
         :from     => "\"#{@conference_name}\" <#{from_address}>",
         :reply_to => "\"#{@conference_name}\" <#{from_address}>",
         :date => sent_at
  end

  def self.send_early_review_submitted(session, sent_at = Time.now)
    I18n.with_locale(session.author.try(:default_locale)) do
      early_review_submitted(session, sent_at).deliver
    end
  end

  def early_review_submitted(session, sent_at = Time.now)
    @session = session
    @conference_name = current_conference.name
    mail :subject => "[#{host}] #{I18n.t('email.early_review_submitted.subject', :session_name => @session.title)}",
         :to      => session.authors.map { |author| "\"#{author.full_name}\" <#{author.email}>" },
         :from     => "\"#{@conference_name}\" <#{from_address}>",
         :reply_to => "\"#{@conference_name}\" <#{from_address}>",
         :date => sent_at
  end

  def self.send_reviewer_invitation(reviewer, sent_at = Time.now)
    I18n.with_locale(reviewer.user.try(:default_locale)) do
      reviewer_invitation(reviewer, sent_at).deliver
    end
  end

  def reviewer_invitation(reviewer, sent_at = Time.now)
    @reviewer = reviewer
    @conference_name = current_conference.name
    mail :subject  => "[#{host}] #{I18n.t('email.reviewer_invitation.subject', :conference_name => @conference_name)}",
         :to       => "\"#{reviewer.user.full_name}\" <#{reviewer.user.email}>",
         :from     => "\"#{@conference_name}\" <#{from_address}>",
         :reply_to => "\"#{@conference_name}\" <#{from_address}>",
         :date     => sent_at
  end

  def self.send_notification_of_acceptance(session, sent_at = Time.now)
    raise "Notification can't be sent before decision has been made" unless session.review_decision
    raise "Cannot accept a rejected session" if session.review_decision.rejected?
    I18n.with_locale(session.author.try(:default_locale)) do
      notification_of_acceptance(session, sent_at).deliver
    end
  end

  def notification_of_acceptance(session, sent_at = Time.now)
    @session = session
    @conference_name = current_conference.name
    mail(:subject  => "[#{host}] #{I18n.t('email.session_accepted.subject', :conference_name => @conference_name)}",
         :to       => session.authors.map { |author| "\"#{author.full_name}\" <#{author.email}>" },
         :from     => "\"#{@conference_name}\" <#{from_address}>",
         :reply_to => "\"#{@conference_name}\" <#{from_address}>",
         :date     => sent_at)
  end

  def self.send_notification_of_rejection(session, sent_at = Time.now)
    raise "Notification can't be sent before decision has been made" unless session.review_decision
    raise "Cannot reject an accepted session" if session.review_decision.accepted?
    I18n.with_locale(session.author.try(:default_locale)) do
      notification_of_rejection(session, sent_at).deliver
    end
  end

  def notification_of_rejection(session, sent_at = Time.now)
    @session = session
    @conference_name = current_conference.name
    mail(:subject  => "[#{host}] #{I18n.t('email.session_rejected.subject', :conference_name => @conference_name)}",
         :to       => session.authors.map { |author| "\"#{author.full_name}\" <#{author.email}>" },
         :from     => "\"#{@conference_name}\" <#{from_address}>",
         :reply_to => "\"#{@conference_name}\" <#{from_address}>",
         :date     => sent_at)
  end

  private
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
