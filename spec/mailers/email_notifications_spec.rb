# encoding: utf-8
require 'spec_helper'

describe EmailNotifications do
  before do
    ActionMailer::Base.deliveries = []
    I18n.locale = I18n.default_locale
    @conference = Conference.current || Factory(:conference)
  end

  after do
    ActionMailer::Base.deliveries.clear
  end

  context "user subscription" do
    before(:each) do
      @user = Factory(:user)
    end
    
    it "should include account details" do
      mail = EmailNotifications.welcome(@user).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@user.email]
  	  mail.encoded.should =~ /#{@user.username}/
  	  mail.subject.should == "[localhost:3000] Cadastro realizado com sucesso"
    end
    
    it "should be sent in system's locale" do
      I18n.locale = 'en'
      mail = EmailNotifications.welcome(@user).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@user.email]
  	  mail.encoded.should =~ /Username.*#{@user.username}/
  	  mail.subject.should == "[localhost:3000] Account registration"
    end
  end

  context "password reset" do
    before(:each) do
      @user = Factory(:user)
    end
    
    it "should include link with perishable_token" do
      @user.send(:generate_reset_password_token!)
      mail = EmailNotifications.reset_password_instructions(@user).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@user.email]
  	  mail.encoded.should =~ /\/password\/edit\?/
      mail.encoded.should =~ /#{@user.reset_password_token}/
  	  mail.subject.should == "[localhost:3000] Recuperação de senha"
    end
    
    it "should be sent in system's locale" do
      I18n.locale = 'en'
      @user.send(:generate_reset_password_token!)
      mail = EmailNotifications.reset_password_instructions(@user).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@user.email]
  	  mail.encoded.should =~ /\/password\/edit\?/
      mail.encoded.should =~ /#{@user.reset_password_token}/
  	  mail.subject.should == "[localhost:3000] Password reset"
    end
  end

  context "session submission" do
    before(:each) do
      @session = Factory(:session)
    end
    
    it "should be sent to first author" do
      mail = EmailNotifications.session_submitted(@session).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@session.author.email]
  	  mail.encoded.should =~ /#{@session.author.full_name},/
  	  mail.encoded.should =~ /#{@session.title}/
  	  mail.encoded.should =~ /\/sessions\/#{@session.to_param}/
  	  mail.subject.should == "[localhost:3000] Proposta de sessão submetida para #{@conference.name}"
    end
    
    it "should be sent to second author, if available" do
      user = Factory(:user)
      @session.second_author = user
      
      mail = EmailNotifications.session_submitted(@session).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@session.author.email, user.email]
  	  mail.encoded.should =~ /#{@session.author.full_name} &amp; #{user.full_name},/
  	  mail.encoded.should =~ /#{@session.title}/
  	  mail.encoded.should =~ /\/sessions\/#{@session.to_param}/
  	  mail.subject.should == "[localhost:3000] Proposta de sessão submetida para #{@conference.name}"
    end
    
    it "should be sent to first author in system's locale" do
      I18n.locale = 'en'
      mail = EmailNotifications.session_submitted(@session).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@session.author.email]
  	  mail.encoded.should =~ /Dear #{@session.author.full_name},/
  	  mail.encoded.should =~ /#{@session.title}/
  	  mail.encoded.should =~ /\/sessions\/#{@session.to_param}/
  	  mail.subject.should == "[localhost:3000] #{@conference.name} session proposal submitted"
    end

    it "should be sent to second author, if available (in system's locale)" do
      I18n.locale = 'en'
      user = Factory(:user, :default_locale => 'fr')
      @session.second_author = user
      
      mail = EmailNotifications.session_submitted(@session).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@session.author.email, user.email]
  	  mail.encoded.should =~ /Dear #{@session.author.full_name} &amp; #{user.full_name},/
  	  mail.encoded.should =~ /#{@session.title}/
  	  mail.encoded.should =~ /\/sessions\/#{@session.to_param}/
  	  mail.subject.should == "[localhost:3000] #{@conference.name} session proposal submitted"
    end
  end

  context "reviewer invitation" do
    before(:each) do
      @reviewer = Factory.build(:reviewer, :id => 3)
    end
    
    it "should include link with invitation" do
      mail = EmailNotifications.reviewer_invitation(@reviewer).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@reviewer.user.email]
  	  mail.encoded.should =~ /\/reviewers\/3\/accept/
  	  mail.encoded.should =~ /\/reviewers\/3\/reject/
  	  mail.subject.should == "[localhost:3000] Convite para equipe de avaliação da #{@conference.name}"
    end

    it "should be sent in user's default language" do
      @reviewer.user.default_locale = 'en'
      mail = EmailNotifications.reviewer_invitation(@reviewer).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@reviewer.user.email]
  	  mail.encoded.should =~ /\/reviewers\/3\/accept/
  	  mail.encoded.should =~ /\/reviewers\/3\/reject/
  	  mail.subject.should == "[localhost:3000] Invitation to be part of #{@conference.name} review committee"
    end
  end
  
  context "notification of acceptance" do
    before(:each) do
      @decision = Factory.build(:review_decision, :outcome => Outcome.find_by_title('outcomes.accept.title'))
      @decision.session.update_attribute(:state, "in_review")
      @decision.save
      @session = @decision.session
    end
    
    it "should not be sent if session has no decision" do
      session = Factory(:session, :conference => @conference)
      lambda {EmailNotifications.notification_of_acceptance(session).deliver}.should raise_error("Notification can't be sent before decision has been made")
    end
    
    it "should not be sent if session has been rejected" do
      @session.review_decision.expects(:rejected?).returns(true)
      
      lambda {EmailNotifications.notification_of_acceptance(@session).deliver}.should raise_error("Cannot accept a rejected session")
    end
    
    it "should be sent to first author" do
      mail = EmailNotifications.notification_of_acceptance(@session).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@session.author.email]
  	  mail.encoded.should =~ /Caro #{@session.author.full_name},/
  	  mail.encoded.should =~ /#{@session.title}/
  	  mail.encoded.should =~ /\/sessions\/#{@session.to_param}/
      mail.encoded.should =~ /\/sessions\/#{@session.to_param}\/confirm/
      mail.encoded.should =~ /\/sessions\/#{@session.to_param}\/withdraw/
  	  
  	  mail.subject.should == "[localhost:3000] Comunicado do Comitê de Programa da #{@conference.name}"
    end
    
    it "should be sent to second author, if available" do
      user = Factory(:user)
      @session.second_author = user
      
      mail = EmailNotifications.notification_of_acceptance(@session).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@session.author.email, user.email]
  	  mail.encoded.should =~ /Caros #{@session.author.full_name} &amp; #{user.full_name},/
  	  mail.encoded.should =~ /#{@session.title}/
  	  mail.encoded.should =~ /\/sessions\/#{@session.to_param}/
      mail.encoded.should =~ /\/sessions\/#{@session.to_param}\/confirm/
      mail.encoded.should =~ /\/sessions\/#{@session.to_param}\/withdraw/

  	  mail.subject.should == "[localhost:3000] Comunicado do Comitê de Programa da #{@conference.name}"
    end
    
    it "should be sent to first author in default language" do
      @session.author.default_locale = 'en'
      mail = EmailNotifications.notification_of_acceptance(@session).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@session.author.email]
  	  mail.encoded.should =~ /Dear #{@session.author.full_name},/
  	  mail.encoded.should =~ /#{@session.title}/
  	  mail.encoded.should =~ /\/sessions\/#{@session.to_param}/
      mail.encoded.should =~ /\/sessions\/#{@session.to_param}\/confirm/
      mail.encoded.should =~ /\/sessions\/#{@session.to_param}\/withdraw/
      
  	  mail.subject.should == "[localhost:3000] Notification from the Program Committee of #{@conference.name}"
    end

    it "should be the same to both authors, if second autor is available" do
      @session.author.default_locale = 'en'
      user = Factory(:user, :default_locale => 'fr')
      @session.second_author = user
      
      mail = EmailNotifications.notification_of_acceptance(@session).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@session.author.email, user.email]
  	  mail.encoded.should =~ /Dear #{@session.author.full_name} &amp; #{user.full_name},/
  	  mail.encoded.should =~ /#{@session.title}/
  	  mail.encoded.should =~ /\/sessions\/#{@session.to_param}/
      mail.encoded.should =~ /\/sessions\/#{@session.to_param}\/confirm/
      mail.encoded.should =~ /\/sessions\/#{@session.to_param}\/withdraw/

  	  mail.subject.should == "[localhost:3000] Notification from the Program Committee of #{@conference.name}"
    end
    
  end
  
  context "notification of rejection" do
    before(:each) do
      @decision = Factory.build(:review_decision, :outcome => Outcome.find_by_title('outcomes.reject.title'))
      @decision.session.update_attribute(:state, "in_review")
      @decision.save
      @session = @decision.session
    end
    
    it "should not be sent if session has no decision" do
      session = Factory(:session, :conference => @conference)
      lambda {EmailNotifications.notification_of_rejection(session).deliver}.should raise_error("Notification can't be sent before decision has been made")
    end
    
    it "should not be sent if session has been accepted" do
      @session.review_decision.expects(:accepted?).returns(true)
      
      lambda {EmailNotifications.notification_of_rejection(@session).deliver}.should raise_error("Cannot reject an accepted session")
    end

    it "should be sent to first author" do
      mail = EmailNotifications.notification_of_rejection(@session).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@session.author.email]
  	  mail.encoded.should =~ /Caro #{@session.author.full_name},/
  	  mail.encoded.should =~ /#{@session.title}/
  	  mail.encoded.should =~ /\/sessions\/#{@session.to_param}/
  	  
  	  mail.subject.should == "[localhost:3000] Comunicado do Comitê de Programa da #{@conference.name}"
    end
    
    it "should be sent to second author, if available" do
      user = Factory(:user)
      @session.second_author = user
      
      mail = EmailNotifications.notification_of_rejection(@session).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@session.author.email, user.email]
  	  mail.encoded.should =~ /Caros #{@session.author.full_name} &amp; #{user.full_name},/
  	  mail.encoded.should =~ /#{@session.title}/
  	  mail.encoded.should =~ /\/sessions\/#{@session.to_param}/

  	  mail.subject.should == "[localhost:3000] Comunicado do Comitê de Programa da #{@conference.name}"
    end
    
    it "should be sent to first author in default language" do
      @session.author.default_locale = 'en'
      mail = EmailNotifications.notification_of_rejection(@session).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@session.author.email]
  	  mail.encoded.should =~ /Dear #{@session.author.full_name},/
  	  mail.encoded.should =~ /#{@session.title}/
  	  mail.encoded.should =~ /\/sessions\/#{@session.to_param}/
      
  	  mail.subject.should == "[localhost:3000] Notification from the Program Committee of #{@conference.name}"
    end

    it "should be the same to both authors, if second autor is available" do
      @session.author.default_locale = 'en'
      user = Factory(:user, :default_locale => 'fr')
      @session.second_author = user
      
      mail = EmailNotifications.notification_of_rejection(@session).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@session.author.email, user.email]
  	  mail.encoded.should =~ /Dear #{@session.author.full_name} &amp; #{user.full_name},/
  	  mail.encoded.should =~ /#{@session.title}/
  	  mail.encoded.should =~ /\/sessions\/#{@session.to_param}/

  	  mail.subject.should == "[localhost:3000] Notification from the Program Committee of #{@conference.name}"
    end 
  end
  
  context "registration pending" do
    before(:each) do
      @attendee = Factory(:attendee, :registration_date => Time.zone.local(2011, 04, 25, 12, 0, 0))
    end
    
    it "should be sent to attendee cc'ed to conference organizer" do
      mail = EmailNotifications.registration_pending(@attendee).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@attendee.email]
      mail.cc.should == [AppConfig[:organizer][:email], AppConfig[:organizer][:cced_email]]
      mail.encoded.should =~ /Caro #{@attendee.full_name},/
      # mail.encoded.should =~ /#{I18n.l(Date.today + 5)},/
      mail.encoded.should =~ /R\$ 165,00/
      # mail.encoded.should =~ /http:\/\/www\.agilebrazil\.com\.br\/2011\/pt\/inscricoes\.php/
      mail.encoded.should =~ /#{AppConfig[:organizer][:email]}/
      mail.subject.should == "[localhost:3000] Pedido de inscrição na #{@conference.name} enviado"
    end
    
    it "should be sent to attendee according to country" do
      @attendee.country = 'US'
      mail = EmailNotifications.registration_pending(@attendee).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@attendee.email]
      mail.cc.should == [AppConfig[:organizer][:email], AppConfig[:organizer][:cced_email]]
      mail.encoded.should =~ /Dear #{@attendee.full_name},/
      mail.encoded.should =~ /R\$ 165,00/
      # mail.encoded.should =~ /#{I18n.l(Date.today + 5)},/
      mail.encoded.should =~ /#{AppConfig[:organizer][:email]}/
      # mail.encoded.should =~ /http:\/\/www\.agilebrazil\.com\.br\/2011\/en\/inscricoes\.php/
      mail.subject.should == "[localhost:3000] Registration request to #{@conference.name} sent"
    end
  end

  context "registration confirmed" do
    before(:each) do
      @attendee = Factory(:attendee, :registration_date => Time.zone.local(2011, 04, 25, 12, 0, 0))
    end
    
    it "should be sent to attendee" do
      mail = EmailNotifications.registration_confirmed(@attendee).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@attendee.email]
      mail.cc.should == []
      mail.encoded.should =~ /Caro #{@attendee.full_name},/
      mail.encoded.should =~ /R\$ 165,00/
      mail.encoded.should =~ /#{AppConfig[:organizer][:email]}/
      mail.subject.should == "[localhost:3000] Inscrição na #{@conference.name} confirmada"
    end

    it "should cc group contact if available" do
      group = Factory(:registration_group)
      @attendee.registration_group = group
      
      mail = EmailNotifications.registration_confirmed(@attendee).deliver
      mail.to.should == [@attendee.email]
      mail.cc.should == [group.contact_email]
    end
    
    it "should be sent to attendee according to country" do
      @attendee.country = 'US'
      mail = EmailNotifications.registration_confirmed(@attendee).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@attendee.email]
      mail.cc.should == []
      mail.encoded.should =~ /Dear #{@attendee.full_name},/
      mail.encoded.should =~ /R\$ 165,00/
      mail.encoded.should =~ /#{AppConfig[:organizer][:email]}/
      mail.subject.should == "[localhost:3000] Registration confirmed for #{@conference.name}"
    end
  end

  context "registration group attendee" do
    before(:each) do
      @registration_group = Factory(:registration_group)
      @attendee = Factory(:attendee,
        :registration_date => Time.zone.local(2011, 04, 25, 12, 0, 0),
        :registration_type => RegistrationType.find_by_title('registration_type.group'),
        :registration_group => @registration_group
      )
    end
    
    it "should be sent to attendee cc'ed to group organizer" do
      mail = EmailNotifications.registration_group_attendee(@attendee, @registration_group).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@attendee.email]
      mail.cc.should == [@registration_group.contact_email]
      mail.encoded.should =~ /Caro #{@attendee.full_name},/
      mail.encoded.should =~ /#{AppConfig[:organizer][:email]}/
      mail.subject.should == "[localhost:3000] Pedido de inscrição em empresa na #{@conference.name} enviado"
    end
  
    it "should be sent to attendee according to country" do
      @attendee.country = 'US'
      mail = EmailNotifications.registration_group_attendee(@attendee, @registration_group).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@attendee.email]
      mail.cc.should == [@registration_group.contact_email]
      mail.encoded.should =~ /Dear #{@attendee.full_name},/
      mail.encoded.should =~ /#{AppConfig[:organizer][:email]}/
      mail.subject.should == "[localhost:3000] Company registration request to #{@conference.name} sent"
    end
  end
    
  context "registration group pending" do
    before(:each) do
      @registration_group = Factory(:registration_group)
      @attendee = Factory(:attendee,
        :registration_date => Time.zone.local(2011, 04, 25, 12, 0, 0),
        :registration_type => RegistrationType.find_by_title('registration_type.group'),
        :registration_group => @registration_group
      )
    end

    it "should be sent to group organizer cc'ed to conference organizer" do
      mail = EmailNotifications.registration_group_pending(@registration_group).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@registration_group.contact_email]
      mail.cc.should == [AppConfig[:organizer][:email], AppConfig[:organizer][:cced_email]]
      mail.encoded.should =~ /#{@registration_group.contact_name},/
      mail.encoded.should =~ /R\$ 135,00/
      mail.encoded.should =~ /#{AppConfig[:organizer][:email]}/
      mail.subject.should == "[localhost:3000] Pedido de inscrição em empresa na #{@conference.name} enviado"
    end
  
    it "should be sent to group organizer according to country" do
      @registration_group.country = 'US'
      mail = EmailNotifications.registration_group_pending(@registration_group).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@registration_group.contact_email]
      mail.cc.should == [AppConfig[:organizer][:email], AppConfig[:organizer][:cced_email]]
      mail.encoded.should =~ /Dear #{@registration_group.contact_name},/
      mail.encoded.should =~ /R\$ 135,00/
      mail.encoded.should =~ /#{AppConfig[:organizer][:email]}/
      mail.subject.should == "[localhost:3000] Company registration request to #{@conference.name} sent"
    end
  end
  
  context "registration reminder" do
    before(:each) do
      @attendee = Factory(:attendee, :registration_date => Time.zone.local(2011, 04, 25, 12, 0, 0))
    end
    
    it "should be sent to attendee cc'ed to conference organizer" do
      mail = EmailNotifications.registration_reminder(@attendee).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@attendee.email]
      mail.cc.should == [AppConfig[:organizer][:email], AppConfig[:organizer][:cced_email]]
      mail.encoded.should =~ /Caro #{@attendee.full_name},/
      mail.encoded.should =~ /#{AppConfig[:organizer][:email]}/
      mail.subject.should == "[localhost:3000] Nova forma de pagamento por Paypal para inscrições na #{@conference.name}"
    end
    
    it "should be sent to attendee using defult_locale" do
      @attendee.default_locale = 'en'
      mail = EmailNotifications.registration_reminder(@attendee).deliver
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@attendee.email]
      mail.cc.should == [AppConfig[:organizer][:email], AppConfig[:organizer][:cced_email]]
      mail.encoded.should =~ /Dear #{@attendee.full_name},/
      mail.encoded.should =~ /#{AppConfig[:organizer][:email]}/
      mail.subject.should == "[localhost:3000] New payment option via Paypal for registration for #{@conference.name}"
    end
  end
  
end
