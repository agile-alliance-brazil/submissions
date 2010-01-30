class EmailNotifications < ActionMailer::Base

  helper :application
  
  def welcome(user, sent_at = Time.now)
    subject    "[#{host}] #{I18n.t('email.welcome.subject')}"
    recipients user.email
    from       "Agile Brazil 2010 <no-reply@#{host}>"
    reply_to   "no-reply@#{host}"
    sent_on    sent_at
    content_type "text/html"
    
    body       :user => user
  end

  private
  def host
    ActionMailer::Base.default_url_options[:host]
  end
end
