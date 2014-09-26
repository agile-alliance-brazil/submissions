# encoding: UTF-8
require 'spec_helper'

shared_examples_for "standard conference e-mail" do
  let(:conference) { FactoryGirl.create(:conference) }

  # TODO: Remove usage of Conference.current
  before(:each) do
    Conference.stubs(:current).returns(conference)
  end

  it { should deliver_from("\"#{conference.name}\" <#{AppConfig[:sender_address]}>") }
  it { should reply_to("\"#{conference.name}\" <#{AppConfig[:sender_address]}>") }
end

describe EmailNotifications, type: :mailer do
  let(:conference) { FactoryGirl.create(:conference) }

  # TODO: Remove usage of Conference.current
  before(:each) do
    Conference.stubs(:current).returns(conference)
  end

  around do |example|
    I18n.with_locale(I18n.default_locale) do
      ActionMailer::Base.deliveries = []
      example.run
      ActionMailer::Base.deliveries.clear
    end
  end

  describe "user subscription e-mail" do
    let(:user) { FactoryGirl.build(:user) }
    subject { EmailNotifications.welcome(user) }

    it_should_behave_like "standard conference e-mail"

    it { should deliver_to(EmailNotifications.send(:format_email, user)) }
    it { should have_body_text(/#{user.username}/) }

    context "in pt" do
      before { user.default_locale = 'pt' }

      it { should have_subject("[localhost:3000] Cadastro realizado com sucesso") }
    end

    context "in en" do
      before { user.default_locale = 'en' }

      it { should have_subject("[localhost:3000] Account registration") }
    end
  end

  describe "reset password instructions e-mail" do
    let(:user) { FactoryGirl.build(:user) }
    before { user.send(:send_reset_password_instructions) }

    subject { EmailNotifications.reset_password_instructions(user, :fake_token) }

    it_should_behave_like "standard conference e-mail"

    it { should deliver_to("#{user.full_name} <#{user.email}>") }
    it { should have_body_text(/\/password\/edit\?/) }
    it { should have_body_text(/fake_token/) }

    context "in pt" do
      before { user.default_locale = 'pt' }

      it { should have_subject("[localhost:3000] Recuperação de senha") }
    end

    context "in en" do
      before { user.default_locale = 'en' }

      it { should have_subject("[localhost:3000] Password reset") }
    end
  end

  describe "session submission e-mail" do
    let(:user) { FactoryGirl.build(:user) }
    let(:session) { FactoryGirl.build(:session, author: user) }

    subject { EmailNotifications.session_submitted(session) }

    it_should_behave_like "standard conference e-mail"

    it { should have_body_text(/#{session.title}/) }
    it { should have_body_text(/\/sessions\/#{session.to_param}/) }

    context "in pt" do
      before { user.default_locale = 'pt' }

      it { should have_subject("[localhost:3000] Proposta de sessão submetida para #{conference.name}") }
      it { should have_body_text(/#{I18n.l(conference.submissions_deadline.to_date, format: :long, locale: :pt)}/) }
    end

    context "in en" do
      before { user.default_locale = 'en' }

      it { should have_subject("[localhost:3000] #{conference.name} session proposal submitted") }
      it { should have_body_text(/#{I18n.l(conference.submissions_deadline.to_date, format: :long, locale: :en)}/) }
    end

    context "with single author" do
      let(:session) { FactoryGirl.build(:session, author: user) }

    it { should deliver_to(EmailNotifications.send(:format_email, user)) }
      it { should have_body_text(/#{session.author.full_name},/) }
    end

    context "with second author" do
      let(:session) { FactoryGirl.build(:session, second_author: user) }

      it { should deliver_to(EmailNotifications.send(:format_email, session.author), EmailNotifications.send(:format_email, user)) }
      it { should have_body_text(/#{session.author.full_name} &amp; #{user.full_name},/) }
    end
  end

  describe "comment submission e-mail" do
    let(:user) { FactoryGirl.build(:user) }
    let(:session) { FactoryGirl.build(:session, author: user) }
    let(:comment) { FactoryGirl.build(:comment, commentable: session) }

    subject { EmailNotifications.comment_submitted(session, comment) }

    it_should_behave_like "standard conference e-mail"

    it { should have_body_text(/#{session.title}/) }
    it { should have_body_text(/\/sessions\/#{session.to_param}.*#comments/) }
    it { should have_body_text(/#{comment.comment}/) }

    context "in pt" do
      before { user.default_locale = 'pt' }

      it { should have_subject("[localhost:3000] Novo comentário para sua sessão '#{session.title}'") }
    end

    context "in en" do
      before { user.default_locale = 'en' }

      it { should have_subject("[localhost:3000] New comment for your session '#{session.title}'") }
    end

    context "with single author" do
      let(:session) { FactoryGirl.build(:session, author: user) }

      it { should deliver_to(EmailNotifications.send(:format_email, user)) }
      it { should have_body_text(/#{session.author.full_name},/)}
    end

    context "with second author" do
      let(:session) { FactoryGirl.build(:session, second_author: user) }

      it { should deliver_to(EmailNotifications.send(:format_email, session.author), EmailNotifications.send(:format_email, user)) }
      it { should have_body_text(/#{session.author.full_name} &amp; #{user.full_name},/) }
    end
  end

  describe "early review submission e-mail" do
    let(:user) { FactoryGirl.build(:user) }
    let(:session) { FactoryGirl.build(:session, author: user) }

    subject { EmailNotifications.early_review_submitted(session) }

    it_should_behave_like "standard conference e-mail"

    it { should have_body_text(/#{session.title}/) }
    it { should have_body_text(/\/sessions\/#{session.to_param}\/reviews.*early/) }

    context "in pt" do
      before { user.default_locale = 'pt' }

      it { should have_subject("[localhost:3000] Pré-avaliação da sua sessão '#{session.title}'") }
    end

    context "in en" do
      before { user.default_locale = 'en' }

      it { should have_subject("[localhost:3000] Early review submitted for your session '#{session.title}'") }
    end

    context "with single author" do
      let(:session) { FactoryGirl.build(:session, author: user) }

      it { should deliver_to(EmailNotifications.send(:format_email, user)) }
      it { should have_body_text(/#{session.author.full_name},/)}
    end

    context "with second author" do
      let(:session) { FactoryGirl.build(:session, second_author: user) }

      it { should deliver_to(EmailNotifications.send(:format_email, session.author), EmailNotifications.send(:format_email, user)) }
      it { should have_body_text(/#{session.author.full_name} &amp; #{user.full_name},/) }
    end
  end

  describe "reviewer invitation e-mail" do
    let(:user) { FactoryGirl.build(:user) }
    let(:reviewer) { FactoryGirl.build(:reviewer, user: user, id: 3) }

    subject { EmailNotifications.reviewer_invitation(reviewer) }

    it_should_behave_like "standard conference e-mail"

    it { should deliver_to(EmailNotifications.send(:format_email, user)) }
    it { should have_body_text(/\/reviewers\/3\/accept/)}
    it { should have_body_text(/\/reviewers\/3\/reject/)}

    context "in pt" do
      before { user.default_locale = 'pt' }

      it { should have_subject("[localhost:3000] Convite para equipe de avaliação da #{conference.name}") }
    end

    context "in en" do
      before { user.default_locale = 'en' }

      it { should have_subject("[localhost:3000] Invitation to be part of #{conference.name} review committee") }
    end
  end

  describe "notification of acceptance e-mail" do
    let(:user) { FactoryGirl.build(:author) }
    let(:session) { FactoryGirl.build(:session, state: 'in_review', author: user) }
    before { session.review_decision = FactoryGirl.build(:review_decision, outcome: Outcome.find_by_title('outcomes.accept.title')) }

    subject { EmailNotifications.notification_of_acceptance(session) }

    it_should_behave_like "standard conference e-mail"

    it "should not be sent if session has no decision" do
      session.review_decision = nil
      expect(lambda {EmailNotifications.notification_of_acceptance(session)}).to raise_error("Notification can't be sent before decision has been made")
    end

    it { should have_body_text(/#{session.title}/)}
    it { should have_body_text(/\/sessions\/#{session.to_param}\/confirm/)}
    it { should have_body_text(/\/sessions\/#{session.to_param}\/withdraw/)}

    context "in pt" do
      before { user.default_locale = 'pt' }

      it { should have_subject("[localhost:3000] Comunicado do Comitê de Programa da #{conference.name}") }
    end

    context "in en" do
      before { user.default_locale = 'en' }

      it { should have_subject("[localhost:3000] Notification from the Program Committee of #{conference.name}") }
    end

    context "with single author" do
      it { should deliver_to(EmailNotifications.send(:format_email, session.author)) }
      it { should have_body_text(/#{session.author.full_name},/)}
    end

    context "with second author" do
      let(:session) { FactoryGirl.build(:session, state: 'in_review', second_author: user) }
      before { session.review_decision = FactoryGirl.build(:review_decision, outcome: Outcome.find_by_title('outcomes.accept.title')) }

      it { should deliver_to(EmailNotifications.send(:format_email, session.author), EmailNotifications.send(:format_email, user)) }
      it { should have_body_text(/#{session.author.full_name} &amp; #{user.full_name},/) }
    end
  end

  describe "notification of rejection e-mail" do
    let(:user) { FactoryGirl.build(:author) }
    let(:session) { FactoryGirl.build(:session, state: 'in_review', author: user) }
    before { session.review_decision = FactoryGirl.build(:review_decision, outcome: Outcome.find_by_title('outcomes.reject.title')) }

    subject { EmailNotifications.notification_of_acceptance(session) }

    it_should_behave_like "standard conference e-mail"

    it "should not be sent if session has no decision" do
      session.review_decision = nil
      expect(lambda {EmailNotifications.notification_of_acceptance(session)}).to raise_error("Notification can't be sent before decision has been made")
    end

    it { should have_body_text(/#{session.title}/)}
    it { should have_body_text(/\/sessions\/#{session.to_param}/)}

    context "in pt" do
      before { user.default_locale = 'pt' }

      it { should have_subject("[localhost:3000] Comunicado do Comitê de Programa da #{conference.name}") }
    end

    context "in en" do
      before { user.default_locale = 'en' }

      it { should have_subject("[localhost:3000] Notification from the Program Committee of #{conference.name}") }
    end

    context "with single author" do
      it { should deliver_to(EmailNotifications.send(:format_email, session.author)) }
      it { should have_body_text(/#{session.author.full_name},/)}
    end

    context "with second author" do
      let(:session) { FactoryGirl.build(:session, state: 'in_review', second_author: user) }
      before { session.review_decision = FactoryGirl.build(:review_decision, outcome: Outcome.find_by_title('outcomes.reject.title')) }

      it { should deliver_to(EmailNotifications.send(:format_email, session.author), EmailNotifications.send(:format_email, user)) }
      it { should have_body_text(/#{session.author.full_name} &amp; #{user.full_name},/) }
    end
  end

  describe "review feedback request" do
    let(:user) { FactoryGirl.build(:author) }

    subject { EmailNotifications.review_feedback_request(user) }

    it_should_behave_like "standard conference e-mail"

    context "in pt" do
      before { user.default_locale = 'pt' }

      it { should have_subject("[localhost:3000] Pedido de feedback sobre as avaliações de suas sessões na #{conference.name}") }
    end

    context "in en" do
      before { user.default_locale = 'en' }

      it { should have_subject("[localhost:3000] Feedback request for the reviews of your sessions for #{conference.name}") }
    end

    context "with single author" do
      it { should deliver_to(EmailNotifications.send(:format_email, user)) }
      it { should have_body_text(/#{user.full_name},/)}
    end
  end
end
