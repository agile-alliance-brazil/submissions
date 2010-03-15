class EmailNotifications < ActionMailer::Base

  helper :application
  
  def welcome(user, sent_at = Time.now)
    subject       "[#{host}] #{I18n.t('email.welcome.subject')}"
    recipients    "\"#{user.full_name}\" <#{user.email}>"
    from          "\"Agile Brazil 2010\" <no-reply@#{host}>"
    reply_to      "\"Agile Brazil 2010\" <no-reply@#{host}>"
    sent_on       sent_at
    
    multipart_content_for(:welcome, :user => user)
  end
  
  def password_reset_instructions(user, sent_at = Time.now)
    subject       "[#{host}] #{I18n.t('email.password_reset.subject')}"
    recipients    "\"#{user.full_name}\" <#{user.email}>"
    from          "\"Agile Brazil 2010\" <no-reply@#{host}>"
    reply_to      "\"Agile Brazil 2010\" <no-reply@#{host}>"
    sent_on       sent_at
    
    multipart_content_for(:password_reset_instructions, :user => user)
  end
  
  def session_submitted(session, sent_at = Time.now)
    subject       "[#{host}] #{I18n.t('email.session_submitted.subject')}"
    recipients    session.authors.map { |author| "\"#{author.full_name}\" <#{author.email}>" }
    from          "\"Agile Brazil 2010\" <no-reply@#{host}>"
    reply_to      "\"Agile Brazil 2010\" <no-reply@#{host}>"
    sent_on       sent_at
    
    multipart_content_for(:session_submitted, :session => session)
  end
  
  def reviewer_invitation(reviewer, sent_at = Time.now)
    subject       "[#{host}] #{I18n.t('email.reviewer_invitation.subject')}"
    recipients    "\"#{reviewer.user.full_name}\" <#{reviewer.user.email}>"
    from          "\"Agile Brazil 2010\" <no-reply@#{host}>"
    reply_to      "\"Agile Brazil 2010\" <no-reply@#{host}>"
    sent_on       sent_at
    
    multipart_content_for(:reviewer_invitation, :reviewer => reviewer)
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
