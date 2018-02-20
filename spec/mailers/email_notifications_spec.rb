# frozen_string_literal: true

require 'spec_helper'

shared_examples_for 'standard conference e-mail' do
  let(:conference) { FactoryBot.create(:conference) }

  # TODO: Remove usage of Conference.current
  before(:each) do
    Conference.stubs(:current).returns(conference)
  end

  it { should deliver_from("\"#{conference.name}\" <#{APP_CONFIG[:sender_address]}>") }
  it { should reply_to("\"#{conference.name}\" <#{APP_CONFIG[:sender_address]}>") }
end

describe EmailNotifications, type: :mailer do
  let(:conference) { FactoryBot.create(:conference) }
  let(:accept_outcome) { FactoryBot.build(:accepted_outcome) }
  let(:reject_outcome) { FactoryBot.build(:rejected_outcome) }
  let(:backup_outcome) { FactoryBot.build(:backup_outcome) }

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

  describe 'user subscription e-mail' do
    let(:user) { FactoryBot.build(:user) }
    subject { EmailNotifications.welcome(user) }

    it_should_behave_like 'standard conference e-mail'

    it { should deliver_to(EmailNotifications.send(:format_email, user)) }
    it { should have_body_text(/#{user.username}/) }

    context 'in pt' do
      before { user.default_locale = 'pt-BR' }

      it { should have_subject('[localhost:3000] Cadastro realizado com sucesso') }
    end

    context 'in en' do
      before { user.default_locale = 'en' }

      it { should have_subject('[localhost:3000] Account registration') }
    end
  end

  describe 'reset password instructions e-mail' do
    let(:user) { FactoryBot.build(:user) }
    before { user.send(:send_reset_password_instructions) }

    subject { EmailNotifications.reset_password_instructions(user, :fake_token) }

    it_should_behave_like 'standard conference e-mail'

    it { should deliver_to("#{user.full_name} <#{user.email}>") }
    it { should have_body_text(%r{/password/edit\?}) }
    it { should have_body_text(/fake_token/) }

    context 'in pt' do
      before { user.default_locale = 'pt-BR' }

      it { should have_subject('[localhost:3000] Recuperação de senha') }
    end

    context 'in en' do
      before { user.default_locale = 'en' }

      it { should have_subject('[localhost:3000] Password reset') }
    end
  end

  describe 'session submission e-mail' do
    let(:user) { FactoryBot.build(:user) }
    let(:session) { FactoryBot.build(:session, author: user) }

    subject { EmailNotifications.session_submitted(session) }

    it_should_behave_like 'standard conference e-mail'

    it { should have_body_text(/#{session.title}/) }
    it { should have_body_text(%r{/sessions/#{session.to_param}}) }

    context 'in pt' do
      before { user.default_locale = 'pt-BR' }

      it { should have_subject("[localhost:3000] Proposta de sessão submetida para #{conference.name}") }
      it { should have_body_text(/#{I18n.l(conference.submissions_deadline.to_date, format: :long, locale: :'pt-BR')}/) }
    end

    context 'in en' do
      before { user.default_locale = 'en' }

      it { should have_subject("[localhost:3000] #{conference.name} session proposal submitted") }
      it { should have_body_text(/#{I18n.l(conference.submissions_deadline.to_date, format: :long, locale: :en)}/) }
    end

    context 'with single author' do
      let(:session) { FactoryBot.build(:session, author: user) }

      it { should deliver_to(EmailNotifications.send(:format_email, user)) }
      it { should have_body_text(/#{session.author.full_name},/) }
    end

    context 'with second author' do
      let(:session) { FactoryBot.build(:session, second_author: user) }

      it { should deliver_to(EmailNotifications.send(:format_email, session.author), EmailNotifications.send(:format_email, user)) }
      it { should have_body_text(/#{session.author.full_name} & #{user.full_name},/) }
    end
  end

  describe 'comment submission e-mail' do
    let(:user) { FactoryBot.build(:user) }
    let(:session) { FactoryBot.build(:session, author: user) }
    let(:comment) { FactoryBot.build(:comment, commentable: session) }

    subject { EmailNotifications.comment_submitted(session, comment) }

    it_should_behave_like 'standard conference e-mail'

    it { should have_body_text(/#{session.title}/) }
    it { should have_body_text(%r{/sessions/#{session.to_param}.*#comments}) }
    it { should have_body_text(/#{comment.comment}/) }

    context 'in pt' do
      before { user.default_locale = 'pt-BR' }

      it { should have_subject("[localhost:3000] Novo comentário para a sessão '#{session.title}'") }
    end

    context 'in en' do
      before { user.default_locale = 'en' }

      it { should have_subject("[localhost:3000] New comment for session '#{session.title}'") }
    end

    context 'with single author' do
      let(:session) { FactoryBot.build(:session, author: user) }

      it { should bcc_to(user.email) }
    end

    context 'with second author' do
      let(:session) { FactoryBot.build(:session, second_author: user) }

      it { should bcc_to(session.author.email, user.email) }
    end

    context 'with commenters' do
      let(:another_user) { FactoryBot.build(:user, email: 'another.user@provider.com') }
      let(:another_comment) { FactoryBot.build(:comment, commentable: session, user: another_user) }

      it 'should be sent to sessions commenters and authors' do
        session.expects(:comments).returns([stub(user: another_user)])
        EmailNotifications.comment_submitted(session, comment)
        should bcc_to(session.author.email, another_user.email)
      end
    end
  end

  describe 'early review submission e-mail' do
    let(:user) { FactoryBot.build(:user) }
    let(:session) { FactoryBot.build(:session, author: user) }

    subject { EmailNotifications.early_review_submitted(session) }

    it_should_behave_like 'standard conference e-mail'

    it { should have_body_text(/#{session.title}/) }
    it { should have_body_text(%r{/sessions/#{session.to_param}/reviews.*early}) }

    context 'in pt' do
      before { user.default_locale = 'pt-BR' }

      it { should have_subject("[localhost:3000] Pré-avaliação da sua sessão '#{session.title}'") }
    end

    context 'in en' do
      before { user.default_locale = 'en' }

      it { should have_subject("[localhost:3000] Early review submitted for your session '#{session.title}'") }
    end

    context 'with single author' do
      let(:session) { FactoryBot.build(:session, author: user) }

      it { should deliver_to(EmailNotifications.send(:format_email, user)) }
      it { should have_body_text(/#{session.author.full_name},/) }
    end

    context 'with second author' do
      let(:session) { FactoryBot.build(:session, second_author: user) }

      it { should deliver_to(EmailNotifications.send(:format_email, session.author), EmailNotifications.send(:format_email, user)) }
      it { should have_body_text(/#{session.author.full_name} & #{user.full_name},/) }
    end
  end

  describe 'reviewer invitation e-mail' do
    let(:user) { FactoryBot.build(:user) }
    let(:reviewer) { FactoryBot.build(:reviewer, user: user, id: 3) }

    subject { EmailNotifications.reviewer_invitation(reviewer) }

    it_should_behave_like 'standard conference e-mail'

    it { should deliver_to(EmailNotifications.send(:format_email, user)) }
    it { should have_body_text(%r{/reviewers/3/accept}) }
    it { should have_body_text(%r{/reviewers/3/reject}) }

    context 'in pt' do
      before { user.default_locale = 'pt-BR' }

      it { should have_subject("[localhost:3000] Convite para integrar a equipe de revisores da #{conference.name}") }
    end

    context 'in en' do
      before { user.default_locale = 'en' }

      it { should have_subject("[localhost:3000] Invitation to be part of #{conference.name} review committee") }
    end
  end

  describe 'notification of acceptance e-mail' do
    let(:user) { FactoryBot.build(:author) }
    let(:session) { FactoryBot.build(:session, state: 'in_review', author: user) }

    subject { EmailNotifications.notification_of_acceptance(session) }

    it 'should not be sent if session has no decision' do
      expect { subject.deliver_now }.to(
        raise_error("Notification can't be sent before decision has been made")
      )
    end

    context 'with review decision' do
      before { session.review_decision = FactoryBot.build(:review_decision, outcome: accept_outcome) }

      it_should_behave_like 'standard conference e-mail'

      it { should have_body_text(/#{session.title}/) }
      it { should have_body_text(%r{/sessions/#{session.to_param}/confirm}) }
      it { should have_body_text(%r{/sessions/#{session.to_param}/withdraw}) }

      context 'in pt' do
        before { user.default_locale = 'pt-BR' }

        it { should have_subject("[localhost:3000] Comunicado do Comitê de Programa da #{conference.name}") }
      end

      context 'in en' do
        before { user.default_locale = 'en' }

        it { should have_subject("[localhost:3000] Notification from the Program Committee of #{conference.name}") }
      end

      context 'with single author' do
        it { should deliver_to(EmailNotifications.send(:format_email, session.author)) }
        it { should have_body_text(/#{session.author.full_name}/) }
      end

      context 'with second author' do
        let(:session) { FactoryBot.build(:session, state: 'in_review', second_author: user) }
        before { session.review_decision = FactoryBot.build(:review_decision, outcome: accept_outcome) }

        it { should deliver_to(EmailNotifications.send(:format_email, session.author), EmailNotifications.send(:format_email, user)) }
        it { should have_body_text(/#{session.author.full_name} & #{user.full_name}/) }
      end
    end
  end

  describe 'notification of rejection e-mail' do
    let(:user) { FactoryBot.build(:author) }
    let(:session) { FactoryBot.build(:session, state: 'in_review', author: user) }

    subject { EmailNotifications.notification_of_acceptance(session) }

    it 'should not be sent if session has no decision' do
      expect { subject.deliver_now }.to(
        raise_error("Notification can't be sent before decision has been made")
      )
    end

    context 'with review decision of rejection' do
      before { session.review_decision = FactoryBot.build(:review_decision, outcome: reject_outcome) }
      it_should_behave_like 'standard conference e-mail'

      it { should have_body_text(/#{session.title}/) }
      it { should have_body_text(%r{/sessions/#{session.to_param}}) }

      context 'in pt' do
        before { user.default_locale = 'pt-BR' }

        it { should have_subject("[localhost:3000] Comunicado do Comitê de Programa da #{conference.name}") }
      end

      context 'in en' do
        before { user.default_locale = 'en' }

        it { should have_subject("[localhost:3000] Notification from the Program Committee of #{conference.name}") }
      end

      context 'with single author' do
        it { should deliver_to(EmailNotifications.send(:format_email, session.author)) }
        it { should have_body_text(/#{session.author.full_name}/) }
      end

      context 'with second author' do
        let(:session) { FactoryBot.build(:session, state: 'in_review', second_author: user) }
        before { session.review_decision = FactoryBot.build(:review_decision, outcome: reject_outcome) }

        it { should deliver_to(EmailNotifications.send(:format_email, session.author), EmailNotifications.send(:format_email, user)) }
        it { should have_body_text(/#{session.author.full_name} & #{user.full_name}/) }
      end
    end

    context 'with review decision of backup' do
      before { session.review_decision = FactoryBot.build(:review_decision, outcome: backup_outcome) }
      it_should_behave_like 'standard conference e-mail'

      it { should have_body_text(/#{session.title}/) }
      it { should have_body_text(%r{/sessions/#{session.to_param}}) }

      context 'in pt' do
        before { user.default_locale = 'pt-BR' }

        it { should have_subject("[localhost:3000] Comunicado do Comitê de Programa da #{conference.name}") }
      end

      context 'in en' do
        before { user.default_locale = 'en' }

        it { should have_subject("[localhost:3000] Notification from the Program Committee of #{conference.name}") }
      end

      context 'with single author' do
        it { should deliver_to(EmailNotifications.send(:format_email, session.author)) }
        it { should have_body_text(/#{session.author.full_name}/) }
      end

      context 'with second author' do
        let(:session) { FactoryBot.build(:session, state: 'in_review', second_author: user) }
        before { session.review_decision = FactoryBot.build(:review_decision, outcome: backup_outcome) }

        it { should deliver_to(EmailNotifications.send(:format_email, session.author), EmailNotifications.send(:format_email, user)) }
        it { should have_body_text(/#{session.author.full_name} & #{user.full_name}/) }
      end
    end
  end

  describe 'review feedback request' do
    let(:user) { FactoryBot.build(:author) }

    subject { EmailNotifications.review_feedback_request(user) }

    it_should_behave_like 'standard conference e-mail'

    context 'in pt' do
      before { user.default_locale = 'pt-BR' }

      it { should have_subject("[localhost:3000] Pedido de feedback sobre as avaliações de suas sessões na #{conference.name}") }
    end

    context 'in en' do
      before { user.default_locale = 'en' }

      it { should have_subject("[localhost:3000] Feedback request for the reviews of your sessions for #{conference.name}") }
    end

    context 'with single author' do
      it { should deliver_to(EmailNotifications.send(:format_email, user)) }
      it { should have_body_text(/#{user.full_name},/) }
    end
  end
end
