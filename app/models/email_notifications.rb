class EmailNotifications < ActionMailer::Base
  helper :application
  
  def welcome(user, sent_at = Time.now)
    I18n.locale = user.try(:default_locale)
    @user = user
    mail :subject => "[#{host}] #{I18n.t('email.welcome.subject')}",
         :to      => "\"#{user.full_name}\" <#{user.email}>",
         :from     => "\"Agile Brazil 2010\" <#{from_address}>",
         :reply_to => "\"Agile Brazil 2010\" <#{from_address}>",
         :date => sent_at
  end
  
  def password_reset_instructions(user, sent_at = Time.now)
    I18n.locale = user.try(:default_locale)
    @user = user
    mail :subject => "[#{host}] #{I18n.t('email.password_reset.subject')}",
         :to      => "\"#{user.full_name}\" <#{user.email}>",
         :from     => "\"Agile Brazil 2010\" <#{from_address}>",
         :reply_to => "\"Agile Brazil 2010\" <#{from_address}>",
         :date => sent_at
  end
  
  def session_submitted(session, sent_at = Time.now)
    I18n.locale = session.author.try(:default_locale)
    @session = session
    mail :subject => "[#{host}] #{I18n.t('email.session_submitted.subject')}",
         :to      => session.authors.map { |author| "\"#{author.full_name}\" <#{author.email}>" },
         :from     => "\"Agile Brazil 2010\" <#{from_address}>",
         :reply_to => "\"Agile Brazil 2010\" <#{from_address}>",
         :date => sent_at
  end
  
  def reviewer_invitation(reviewer, sent_at = Time.now)
    I18n.locale = reviewer.user.try(:default_locale)
    @reviewer = reviewer
    mail :subject  => "[#{host}] #{I18n.t('email.reviewer_invitation.subject')}",
         :to       => "\"#{reviewer.user.full_name}\" <#{reviewer.user.email}>",
         :from     => "\"Agile Brazil 2010\" <#{from_address}>",
         :reply_to => "\"Agile Brazil 2010\" <#{from_address}>",
         :date     => sent_at
  end

  def notification_of_acceptance(session, sent_at = Time.now)
    raise "Notification can't be sent before decision has been made" unless session.review_decision
    raise "Cannot accept a rejected session" if session.review_decision.rejected?
    I18n.locale = session.author.try(:default_locale)

    @session = session
    mail(:subject  => "[#{host}] #{I18n.t('email.session_accepted.subject')}",
         :to       => session.authors.map { |author| "\"#{author.full_name}\" <#{author.email}>" },
         :from     => "\"Agile Brazil 2010\" <#{from_address}>",
         :reply_to => "\"Agile Brazil 2010\" <#{from_address}>",
         :date     => sent_at).tap do
      session.review_decision.update_attribute(:published, true)
    end
  end

  def notification_of_rejection(session, sent_at = Time.now)
    raise "Notification can't be sent before decision has been made" unless session.review_decision
    raise "Cannot reject an accepted session" if session.review_decision.accepted?
    I18n.locale = session.author.try(:default_locale)

    @session = session
    mail(:subject  => "[#{host}] #{I18n.t('email.session_rejected.subject')}",
         :to       => session.authors.map { |author| "\"#{author.full_name}\" <#{author.email}>" },
         :from     => "\"Agile Brazil 2010\" <#{from_address}>",
         :reply_to => "\"Agile Brazil 2010\" <#{from_address}>",
         :date     => sent_at).tap do
      session.review_decision.update_attribute(:published, true)
    end
  end

  private
  def from_address
    ActionMailer::Base.smtp_settings[:user_name]
  end

  def host
    ActionMailer::Base.default_url_options[:host]
  end  
end
