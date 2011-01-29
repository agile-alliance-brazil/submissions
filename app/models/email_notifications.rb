class EmailNotifications < ActionMailer::Base

  helper :application
  
  def welcome(user, sent_at = Time.now)
    I18n.locale = user.default_locale
    subject       "[#{host}] #{I18n.t('email.welcome.subject')}"
    recipients    "\"#{user.full_name}\" <#{user.email}>"
    from          "\"Agile Brazil 2010\" <no-reply@#{host}>"
    reply_to      "\"Agile Brazil 2010\" <no-reply@#{host}>"
    sent_on       sent_at
    
    multipart_content_for(:welcome, :user => user)
  end
  
  def password_reset_instructions(user, sent_at = Time.now)
    I18n.locale = user.default_locale
    subject       "[#{host}] #{I18n.t('email.password_reset.subject')}"
    recipients    "\"#{user.full_name}\" <#{user.email}>"
    from          "\"Agile Brazil 2010\" <no-reply@#{host}>"
    reply_to      "\"Agile Brazil 2010\" <no-reply@#{host}>"
    sent_on       sent_at
    
    multipart_content_for(:password_reset_instructions, :user => user)
  end
  
  def session_submitted(session, sent_at = Time.now)
    I18n.locale = session.author.try(:default_locale)
    subject       "[#{host}] #{I18n.t('email.session_submitted.subject')}"
    recipients    session.authors.map { |author| "\"#{author.full_name}\" <#{author.email}>" }
    from          "\"Agile Brazil 2010\" <no-reply@#{host}>"
    reply_to      "\"Agile Brazil 2010\" <no-reply@#{host}>"
    sent_on       sent_at
    
    multipart_content_for(:session_submitted, :session => session)
  end
  
  def reviewer_invitation(reviewer, sent_at = Time.now)
    I18n.locale = reviewer.user.try(:default_locale)
    subject       "[#{host}] #{I18n.t('email.reviewer_invitation.subject')}"
    recipients    "\"#{reviewer.user.full_name}\" <#{reviewer.user.email}>"
    from          "\"Agile Brazil 2010\" <no-reply@#{host}>"
    reply_to      "\"Agile Brazil 2010\" <no-reply@#{host}>"
    sent_on       sent_at
    
    multipart_content_for(:reviewer_invitation, :reviewer => reviewer)
  end

  def notification_of_acceptance(session, sent_at = Time.now)
    raise "Notification can't be sent before decision has been made" unless session.review_decision
    raise "Cannot accept a rejected session" if session.review_decision.rejected?
    I18n.locale = session.author.try(:default_locale)
    subject       "[#{host}] #{I18n.t('email.session_accepted.subject')}"
    recipients    session.authors.map { |author| "\"#{author.full_name}\" <#{author.email}>" }
    from          "\"Agile Brazil 2010\" <no-reply@#{host}>"
    reply_to      "\"Agile Brazil 2010\" <no-reply@#{host}>"
    sent_on       sent_at
    
    multipart_content_for(:session_accepted, :session => session).tap do
      session.review_decision.update_attribute(:published, true)
    end
  end

  def notification_of_rejection(session, sent_at = Time.now)
    raise "Notification can't be sent before decision has been made" unless session.review_decision
    raise "Cannot reject an accepted session" if session.review_decision.accepted?
    I18n.locale = session.author.try(:default_locale)
    subject       "[#{host}] #{I18n.t('email.session_rejected.subject')}"
    recipients    session.authors.map { |author| "\"#{author.full_name}\" <#{author.email}>" }
    from          "\"Agile Brazil 2010\" <no-reply@#{host}>"
    reply_to      "\"Agile Brazil 2010\" <no-reply@#{host}>"
    sent_on       sent_at
    
    multipart_content_for(:session_rejected, :session => session).tap do
      session.review_decision.update_attribute(:published, true)
    end
  end

  private
  def host
    ActionMailer::Base.default_url_options[:host]
  end
  
  def multipart_content_for(action, context)
    content_type  "multipart/alternative"
    
    part "text/plain" do |p|
      p.body = render_message("#{action.to_s}_txt", context)
    end
    
    part "text/html" do |p|
      p.body = render_message("#{action.to_s}_html", context)
    end
  end
end
