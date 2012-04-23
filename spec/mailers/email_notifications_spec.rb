# encoding: UTF-8
require 'spec_helper'

describe EmailNotifications do
  subject { EmailNotifications }

  before do
    ActionMailer::Base.deliveries = []
    I18n.locale = I18n.default_locale
    @conference = Conference.current
  end

  after do
    ActionMailer::Base.deliveries.clear
    I18n.locale = I18n.default_locale
  end

  describe "user subscription e-mail" do
    context "in pt" do
      before(:each) do
        @user = FactoryGirl.build(:user, :default_locale => 'pt')
        EmailNotifications.send_welcome(@user)
      end

      it { should have_sent_email.with_subject("[localhost:3000] Cadastro realizado com sucesso") }
      it { should have_sent_email.to(@user.email) }
      it { should have_sent_email.with_body(/#{@user.username}/)}
    end

    context "in en" do
      before(:each) do
        @user = FactoryGirl.build(:user, :default_locale => 'en')
        EmailNotifications.send_welcome(@user)
      end

      it { should have_sent_email.with_subject("[localhost:3000] Account registration") }
      it { should have_sent_email.to(@user.email) }
      it { should have_sent_email.with_body(/Username.*#{@user.username}/)}
    end
  end

  describe "reset password instructions e-mail" do
    context "in pt" do
      before(:each) do
        @user = FactoryGirl.build(:user, :default_locale => 'pt')
        @user.send(:generate_reset_password_token!)
        EmailNotifications.send_reset_password_instructions(@user)
      end

      it { should have_sent_email.with_subject("[localhost:3000] Recuperação de senha") }
      it { should have_sent_email.to(@user.email) }
      it { should have_sent_email.with_body(/\/password\/edit\?/)}
      it { should have_sent_email.with_body(/#{@user.reset_password_token}/)}
    end

    context "in en" do
      before(:each) do
        @user = FactoryGirl.build(:user, :default_locale => 'en')
        @user.send(:generate_reset_password_token!)
        EmailNotifications.send_reset_password_instructions(@user)
      end

      it { should have_sent_email.with_subject("[localhost:3000] Password reset") }
      it { should have_sent_email.to(@user.email) }
      it { should have_sent_email.with_body(/\/password\/edit\?/)}
      it { should have_sent_email.with_body(/#{@user.reset_password_token}/)}
    end
  end

  describe "session submission e-mail" do
    context "in pt" do
      before(:each) do
        @user = FactoryGirl.build(:author, :default_locale => 'pt')
      end

      context "with single author" do
        before(:each) do
          @session = FactoryGirl.build(:session, :author => @user)
          EmailNotifications.send_session_submitted(@session)
        end

        it { should have_sent_email.with_subject("[localhost:3000] Proposta de sessão submetida para #{@conference.name}") }
        it { should have_sent_email.to(@user.email) }
        it { should have_sent_email.with_body(/#{@session.author.full_name},/)}
        it { should have_sent_email.with_body(/#{@session.title}/)}
        it { should have_sent_email.with_body(/\/sessions\/#{@session.to_param}/)}
        it { should have_sent_email.with_body(/#{I18n.l(@conference.submissions_deadline.to_date, :format => :long)}/)}
      end

      context "with second author" do
        before(:each) do
          @session = FactoryGirl.build(:session, :second_author => @user)
          EmailNotifications.send_session_submitted(@session)
        end

        it { should have_sent_email.with_subject("[localhost:3000] Proposta de sessão submetida para #{@conference.name}") }
        it { should have_sent_email.to(@session.author.email) }
        it { should have_sent_email.to(@user.email) }
        it { should have_sent_email.with_body(/#{@session.author.full_name} &amp; #{@user.full_name},/)}
        it { should have_sent_email.with_body(/#{@session.title}/)}
        it { should have_sent_email.with_body(/\/sessions\/#{@session.to_param}/)}
        it { should have_sent_email.with_body(/#{I18n.l(@conference.submissions_deadline.to_date, :format => :long)}/)}
      end
    end

    context "in en" do
      before(:each) do
        @user = FactoryGirl.build(:author, :default_locale => 'en')
      end

      context "with single author" do
        before(:each) do
          @session = FactoryGirl.build(:session, :author => @user)
          EmailNotifications.send_session_submitted(@session)
        end

        it { should have_sent_email.with_subject("[localhost:3000] #{@conference.name} session proposal submitted") }
        it { should have_sent_email.to(@user.email) }
        it { should have_sent_email.with_body(/Dear #{@session.author.full_name},/)}
        it { should have_sent_email.with_body(/#{@session.title}/)}
        it { should have_sent_email.with_body(/\/sessions\/#{@session.to_param}/)}
        it { should have_sent_email.with_body(/#{I18n.l(@conference.submissions_deadline.to_date, :format => :long, :locale => 'en')}/)}
      end

      context "with second author" do
        before(:each) do
          user = FactoryGirl.build(:author, :default_locale => 'en')
          @session = FactoryGirl.build(:session, :author => user, :second_author => @user)
          EmailNotifications.send_session_submitted(@session)
        end

        it { should have_sent_email.with_subject("[localhost:3000] #{@conference.name} session proposal submitted") }
        it { should have_sent_email.to(@session.author.email) }
        it { should have_sent_email.to(@user.email) }
        it { should have_sent_email.with_body(/Dear #{@session.author.full_name} &amp; #{@user.full_name},/)}
        it { should have_sent_email.with_body(/#{@session.title}/)}
        it { should have_sent_email.with_body(/\/sessions\/#{@session.to_param}/)}
        it { should have_sent_email.with_body(/#{I18n.l(@conference.submissions_deadline.to_date, :format => :long, :locale => 'en')}/)}
      end
    end
  end

  describe "comment submission e-mail" do
    context "in pt" do
      before(:each) do
        @user = FactoryGirl.build(:author, :default_locale => 'pt')
      end

      context "with single author" do
        before(:each) do
          @session = FactoryGirl.build(:session, :author => @user)
          @comment = FactoryGirl.build(:comment, :commentable => @session)
          EmailNotifications.send_comment_submitted(@session, @comment)
        end

        it { should have_sent_email.with_subject("[localhost:3000] Novo comentário para sua sessão '#{@session.title}'") }
        it { should have_sent_email.to(@user.email) }
        it { should have_sent_email.with_body(/#{@session.author.full_name},/)}
        it { should have_sent_email.with_body(/#{@session.title}/)}
        it { should have_sent_email.with_body(/\/sessions\/#{@session.to_param}.*#comments/)}
        it { should have_sent_email.with_body(/#{@comment.comment}/)}
      end

      context "with second author" do
        before(:each) do
          @session = FactoryGirl.build(:session, :second_author => @user)
          @comment = FactoryGirl.build(:comment, :commentable => @session)
          EmailNotifications.send_comment_submitted(@session, @comment)
        end

        it { should have_sent_email.with_subject("[localhost:3000] Novo comentário para sua sessão '#{@session.title}'") }
        it { should have_sent_email.to(@session.author.email) }
        it { should have_sent_email.to(@user.email) }
        it { should have_sent_email.with_body(/#{@session.author.full_name} &amp; #{@user.full_name},/)}
        it { should have_sent_email.with_body(/#{@session.title}/)}
        it { should have_sent_email.with_body(/\/sessions\/#{@session.to_param}.*#comments/)}
        it { should have_sent_email.with_body(/#{@comment.comment}/)}
      end
    end

    context "in en" do
      before(:each) do
        @user = FactoryGirl.build(:author, :default_locale => 'en')
      end

      context "with single author" do
        before(:each) do
          @session = FactoryGirl.build(:session, :author => @user)
          @comment = FactoryGirl.build(:comment, :commentable => @session)
          EmailNotifications.send_comment_submitted(@session, @comment)
        end

        it { should have_sent_email.with_subject("[localhost:3000] New comment for your session '#{@session.title}'") }
        it { should have_sent_email.to(@user.email) }
        it { should have_sent_email.with_body(/Dear #{@session.author.full_name},/)}
        it { should have_sent_email.with_body(/#{@session.title}/)}
        it { should have_sent_email.with_body(/\/sessions\/#{@session.to_param}.*#comments/)}
        it { should have_sent_email.with_body(/#{@comment.comment}/)}
      end

      context "with second author" do
        before(:each) do
          user = FactoryGirl.build(:author, :default_locale => 'en')
          @session = FactoryGirl.build(:session, :author => user, :second_author => @user)
          @comment = FactoryGirl.build(:comment, :commentable => @session)
          EmailNotifications.send_comment_submitted(@session, @comment)
        end

        it { should have_sent_email.with_subject("[localhost:3000] New comment for your session '#{@session.title}'") }
        it { should have_sent_email.to(@session.author.email) }
        it { should have_sent_email.to(@user.email) }
        it { should have_sent_email.with_body(/Dear #{@session.author.full_name} &amp; #{@user.full_name},/)}
        it { should have_sent_email.with_body(/#{@session.title}/)}
        it { should have_sent_email.with_body(/\/sessions\/#{@session.to_param}.*#comments/)}
        it { should have_sent_email.with_body(/#{@comment.comment}/)}
      end
    end
  end

  describe "early review submitted e-mail" do
    context "in pt" do
      before(:each) do
        @user = FactoryGirl.build(:author, :default_locale => 'pt')
      end

      context "with single author" do
        before(:each) do
          @session = FactoryGirl.build(:session, :author => @user)
          EmailNotifications.send_early_review_submitted(@session)
        end

        it { should have_sent_email.with_subject("[localhost:3000] Pré-avaliação da sua sessão '#{@session.title}'") }
        it { should have_sent_email.to(@user.email) }
        it { should have_sent_email.with_body(/#{@session.author.full_name},/) }
        it { should have_sent_email.with_body(/#{@session.title}/) }
        it { should have_sent_email.with_body(/\/sessions\/#{@session.to_param}\/reviews.*early/) }
      end

      context "with second author" do
        before(:each) do
          @session = FactoryGirl.build(:session, :second_author => @user)
          EmailNotifications.send_early_review_submitted(@session)
        end

        it { should have_sent_email.with_subject("[localhost:3000] Pré-avaliação da sua sessão '#{@session.title}'") }
        it { should have_sent_email.to(@session.author.email) }
        it { should have_sent_email.to(@user.email) }
        it { should have_sent_email.with_body(/#{@session.author.full_name} &amp; #{@user.full_name},/) }
        it { should have_sent_email.with_body(/#{@session.title}/) }
        it { should have_sent_email.with_body(/\/sessions\/#{@session.to_param}\/reviews.*early/) }
      end
    end

    context "in en" do
      before(:each) do
        @user = FactoryGirl.build(:author, :default_locale => 'en')
      end

      context "with single author" do
        before(:each) do
          @session = FactoryGirl.build(:session, :author => @user)
          EmailNotifications.send_early_review_submitted(@session)
        end

        it { should have_sent_email.with_subject("[localhost:3000] Early review submitted for your session '#{@session.title}'") }
        it { should have_sent_email.to(@user.email) }
        it { should have_sent_email.with_body(/Dear #{@session.author.full_name},/)}
        it { should have_sent_email.with_body(/#{@session.title}/)}
        it { should have_sent_email.with_body(/\/sessions\/#{@session.to_param}\/reviews.*early/)}
      end

      context "with second author" do
        before(:each) do
          user = FactoryGirl.build(:author, :default_locale => 'en')
          @session = FactoryGirl.build(:session, :author => user, :second_author => @user)
          EmailNotifications.send_early_review_submitted(@session)
        end

        it { should have_sent_email.with_subject("[localhost:3000] Early review submitted for your session '#{@session.title}'") }
        it { should have_sent_email.to(@session.author.email) }
        it { should have_sent_email.to(@user.email) }
        it { should have_sent_email.with_body(/Dear #{@session.author.full_name} &amp; #{@user.full_name},/)}
        it { should have_sent_email.with_body(/#{@session.title}/)}
        it { should have_sent_email.with_body(/\/sessions\/#{@session.to_param}\/reviews.*early/)}
      end
    end
  end

  describe "reviewer invitation e-mail" do
    context "in pt" do
      before(:each) do
        @user = FactoryGirl.build(:user, :default_locale => 'pt')
        @reviewer = FactoryGirl.build(:reviewer, :user => @user, :id => 3)
        EmailNotifications.send_reviewer_invitation(@reviewer)
      end

      it { should have_sent_email.with_subject("[localhost:3000] Convite para equipe de avaliação da #{@conference.name}") }
      it { should have_sent_email.to(@user.email) }
      it { should have_sent_email.with_body(/\/reviewers\/3\/accept/)}
      it { should have_sent_email.with_body(/\/reviewers\/3\/reject/)}
    end

    context "in en" do
      before(:each) do
        @user = FactoryGirl.build(:user, :default_locale => 'en')
        @reviewer = FactoryGirl.build(:reviewer, :user => @user, :id => 3)
        EmailNotifications.send_reviewer_invitation(@reviewer)
      end

      it { should have_sent_email.with_subject("[localhost:3000] Invitation to be part of #{@conference.name} review committee") }
      it { should have_sent_email.to(@user.email) }
      it { should have_sent_email.with_body(/\/reviewers\/3\/accept/)}
      it { should have_sent_email.with_body(/\/reviewers\/3\/reject/)}
    end
  end

  describe "notification of acceptance e-mail" do
    before(:each) do
      @session = FactoryGirl.build(:session, :state => 'in_review')
      @session.review_decision = FactoryGirl.build(:review_decision, :outcome => Outcome.find_by_title('outcomes.accept.title'))
    end

    it "should not be sent if session has no decision" do
      session = FactoryGirl.build(:session, :conference => @conference)
      lambda {EmailNotifications.send_notification_of_acceptance(session)}.should raise_error("Notification can't be sent before decision has been made")
    end

    it "should not be sent if session has been rejected" do
      @session.review_decision.expects(:rejected?).returns(true)

      lambda {EmailNotifications.send_notification_of_acceptance(@session)}.should raise_error("Cannot accept a rejected session")
    end

    context "in pt" do
      before(:each) do
        @session.author.default_locale = 'pt'
      end

      context "with single author" do
        before(:each) do
          EmailNotifications.send_notification_of_acceptance(@session)
        end

        it { should have_sent_email.with_subject("[localhost:3000] Comunicado do Comitê de Programa da #{@conference.name}") }
        it { should have_sent_email.to(@session.author.email) }
        it { should have_sent_email.with_body(/Caro #{@session.author.full_name},/)}
        it { should have_sent_email.with_body(/#{@session.title}/)}
        it { should have_sent_email.with_body(/\/sessions\/#{@session.to_param}\/confirm/)}
        it { should have_sent_email.with_body(/\/sessions\/#{@session.to_param}\/withdraw/)}
      end

      context "with second author" do
        before(:each) do
          @session.second_author = FactoryGirl.build(:author)
          EmailNotifications.send_notification_of_acceptance(@session)
        end

        it { should have_sent_email.with_subject("[localhost:3000] Comunicado do Comitê de Programa da #{@conference.name}") }
        it { should have_sent_email.to(@session.author.email) }
        it { should have_sent_email.to(@session.second_author.email) }
        it { should have_sent_email.with_body(/Caros #{@session.author.full_name} &amp; #{@session.second_author.full_name},/)}
        it { should have_sent_email.with_body(/#{@session.title}/)}
        it { should have_sent_email.with_body(/\/sessions\/#{@session.to_param}\/confirm/)}
        it { should have_sent_email.with_body(/\/sessions\/#{@session.to_param}\/withdraw/)}
      end
    end

    context "in en" do
      before(:each) do
        @session.author.default_locale = 'en'
      end

      context "with single author" do
        before(:each) do
          EmailNotifications.send_notification_of_acceptance(@session)
        end

        it { should have_sent_email.with_subject("[localhost:3000] Notification from the Program Committee of #{@conference.name}") }
        it { should have_sent_email.to(@session.author.email) }
        it { should have_sent_email.with_body(/Dear #{@session.author.full_name},/)}
        it { should have_sent_email.with_body(/#{@session.title}/)}
        it { should have_sent_email.with_body(/\/sessions\/#{@session.to_param}\/confirm/)}
        it { should have_sent_email.with_body(/\/sessions\/#{@session.to_param}\/withdraw/)}
      end

      context "with second author" do
        before(:each) do
          @session.second_author = FactoryGirl.build(:author)
          EmailNotifications.send_notification_of_acceptance(@session)
        end

        it { should have_sent_email.with_subject("[localhost:3000] Notification from the Program Committee of #{@conference.name}") }
        it { should have_sent_email.to(@session.author.email) }
        it { should have_sent_email.to(@session.second_author.email) }
        it { should have_sent_email.with_body(/Dear #{@session.author.full_name} &amp; #{@session.second_author.full_name},/)}
        it { should have_sent_email.with_body(/#{@session.title}/)}
        it { should have_sent_email.with_body(/\/sessions\/#{@session.to_param}\/confirm/)}
        it { should have_sent_email.with_body(/\/sessions\/#{@session.to_param}\/withdraw/)}
      end
    end
  end

  describe "notification of rejection e-mail" do
    before(:each) do
      @session = FactoryGirl.build(:session, :state => 'in_review')
      @session.review_decision = FactoryGirl.build(:review_decision, :outcome => Outcome.find_by_title('outcomes.reject.title'))
    end

    it "should not be sent if session has no decision" do
      session = FactoryGirl.build(:session, :conference => @conference)
      lambda {EmailNotifications.send_notification_of_rejection(session)}.should raise_error("Notification can't be sent before decision has been made")
    end

    it "should not be sent if session has been accepted" do
      @session.review_decision.expects(:accepted?).returns(true)

      lambda {EmailNotifications.send_notification_of_rejection(@session)}.should raise_error("Cannot reject an accepted session")
    end

    context "in pt" do
      before(:each) do
        @session.author.default_locale = 'pt'
      end

      context "with single author" do
        before(:each) do
          EmailNotifications.send_notification_of_rejection(@session)
        end

        it { should have_sent_email.with_subject("[localhost:3000] Comunicado do Comitê de Programa da #{@conference.name}") }
        it { should have_sent_email.to(@session.author.email) }
        it { should have_sent_email.with_body(/Caro #{@session.author.full_name},/)}
        it { should have_sent_email.with_body(/#{@session.title}/)}
        it { should have_sent_email.with_body(/\/sessions\/#{@session.to_param}/)}
      end

      context "with second author" do
        before(:each) do
          @session.second_author = FactoryGirl.build(:author)
          EmailNotifications.send_notification_of_rejection(@session)
        end

        it { should have_sent_email.with_subject("[localhost:3000] Comunicado do Comitê de Programa da #{@conference.name}") }
        it { should have_sent_email.to(@session.author.email) }
        it { should have_sent_email.to(@session.second_author.email) }
        it { should have_sent_email.with_body(/Caros #{@session.author.full_name} &amp; #{@session.second_author.full_name},/)}
        it { should have_sent_email.with_body(/#{@session.title}/)}
        it { should have_sent_email.with_body(/\/sessions\/#{@session.to_param}/)}
      end
    end

    context "in en" do
      before(:each) do
        @session.author.default_locale = 'en'
      end

      context "with single author" do
        before(:each) do
          EmailNotifications.send_notification_of_rejection(@session)
        end

        it { should have_sent_email.with_subject("[localhost:3000] Notification from the Program Committee of #{@conference.name}") }
        it { should have_sent_email.to(@session.author.email) }
        it { should have_sent_email.with_body(/Dear #{@session.author.full_name},/)}
        it { should have_sent_email.with_body(/#{@session.title}/)}
        it { should have_sent_email.with_body(/\/sessions\/#{@session.to_param}/)}
      end

      context "with second author" do
        before(:each) do
          @session.second_author = FactoryGirl.build(:author)
          EmailNotifications.send_notification_of_rejection(@session)
        end

        it { should have_sent_email.with_subject("[localhost:3000] Notification from the Program Committee of #{@conference.name}") }
        it { should have_sent_email.to(@session.author.email) }
        it { should have_sent_email.to(@session.second_author.email) }
        it { should have_sent_email.with_body(/Dear #{@session.author.full_name} &amp; #{@session.second_author.full_name},/)}
        it { should have_sent_email.with_body(/#{@session.title}/)}
        it { should have_sent_email.with_body(/\/sessions\/#{@session.to_param}/)}
      end
    end
  end
end
