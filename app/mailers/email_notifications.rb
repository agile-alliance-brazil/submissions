class EmailNotifications < ActionMailer::Base
  def welcome(user, sent_at = Time.now)
    @user = user
    @conference_name = current_conference.name
    mail :subject => "[#{host}] #{I18n.t('email.welcome.subject')}",
         :to      => "\"#{user.full_name}\" <#{user.email}>",
         :from     => "\"#{@conference_name}\" <#{from_address}>",
         :reply_to => "\"#{@conference_name}\" <#{from_address}>",
         :date => sent_at
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
  
  def session_submitted(session, sent_at = Time.now)
    @session = session
    @conference_name = current_conference.name
    mail :subject => "[#{host}] #{I18n.t('email.session_submitted.subject', :conference_name => current_conference.name)}",
         :to      => session.authors.map { |author| "\"#{author.full_name}\" <#{author.email}>" },
         :from     => "\"#{@conference_name}\" <#{from_address}>",
         :reply_to => "\"#{@conference_name}\" <#{from_address}>",
         :date => sent_at
  end
  
  def reviewer_invitation(reviewer, sent_at = Time.now)
    I18n.locale = reviewer.user.try(:default_locale)
    @reviewer = reviewer
    @conference_name = current_conference.name
    mail :subject  => "[#{host}] #{I18n.t('email.reviewer_invitation.subject', :conference_name => current_conference.name)}",
         :to       => "\"#{reviewer.user.full_name}\" <#{reviewer.user.email}>",
         :from     => "\"#{@conference_name}\" <#{from_address}>",
         :reply_to => "\"#{@conference_name}\" <#{from_address}>",
         :date     => sent_at
  end

  def notification_of_acceptance(session, sent_at = Time.now)
    raise "Notification can't be sent before decision has been made" unless session.review_decision
    raise "Cannot accept a rejected session" if session.review_decision.rejected?
    I18n.locale = session.author.try(:default_locale)

    @session = session
    @conference_name = current_conference.name
    mail(:subject  => "[#{host}] #{I18n.t('email.session_accepted.subject', :conference_name => current_conference.name)}",
         :to       => session.authors.map { |author| "\"#{author.full_name}\" <#{author.email}>" },
         :from     => "\"#{@conference_name}\" <#{from_address}>",
         :reply_to => "\"#{@conference_name}\" <#{from_address}>",
         :date     => sent_at).tap do
      session.review_decision.update_attribute(:published, true)
    end
  end

  def notification_of_rejection(session, sent_at = Time.now)
    raise "Notification can't be sent before decision has been made" unless session.review_decision
    raise "Cannot reject an accepted session" if session.review_decision.accepted?
    I18n.locale = session.author.try(:default_locale)

    @session = session
    @conference_name = current_conference.name
    mail(:subject  => "[#{host}] #{I18n.t('email.session_rejected.subject', :conference_name => current_conference.name)}",
         :to       => session.authors.map { |author| "\"#{author.full_name}\" <#{author.email}>" },
         :from     => "\"#{@conference_name}\" <#{from_address}>",
         :reply_to => "\"#{@conference_name}\" <#{from_address}>",
         :date     => sent_at).tap do
      session.review_decision.update_attribute(:published, true)
    end
  end

  def registration_pending(attendee, sent_at = Time.now)
    @now = sent_at
    @attendee = attendee
    periods = RegistrationPeriod.for(@now)
    @registration_period = attendee.pre_registered? ? periods.last : periods.first
    @conference_name = current_conference.name
    mail :subject => "[#{host}] #{I18n.t('email.registration_pending.subject', :conference_name => current_conference.name)}",
         :to      => "\"#{attendee.full_name}\" <#{attendee.email}>",
         :cc       => conference_organizer,
         :from     => "\"#{@conference_name}\" <#{from_address}>",
         :reply_to => "\"#{@conference_name}\" <#{from_address}>",
         :date => sent_at
  end

  private
  def from_address
    ActionMailer::Base.smtp_settings[:user_name]
  end

  def host
    ActionMailer::Base.default_url_options[:host]
  end
  
  def conference_organizer
    "\"#{AppConfig[:organizer][:name]}\" <#{AppConfig[:organizer][:email]}>, \"#{AppConfig[:organizer][:cced]}\" <#{AppConfig[:organizer][:cced_email]}>"
  end

  def current_conference
    @current_conference ||= Conference.current
  end
end
