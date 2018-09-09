# frozen_string_literal: true

require 'spec_helper'

shared_examples_for 'standard conference e-mail' do
  let(:conference) { FactoryBot.create(:conference) }

  # TODO: Remove usage of Conference.current
  before do
    Conference.stubs(:current).returns(conference)
  end

  it { is_expected.to deliver_from("\"#{conference.name}\" <#{APP_CONFIG[:sender_address]}>") }
  it { is_expected.to reply_to("\"#{conference.name}\" <#{APP_CONFIG[:sender_address]}>") }
end

describe EmailNotifications, type: :mailer do
  let(:conference) { FactoryBot.create(:conference) }
  let(:accept_outcome) { FactoryBot.build(:accepted_outcome) }
  let(:reject_outcome) { FactoryBot.build(:rejected_outcome) }
  let(:backup_outcome) { FactoryBot.build(:backup_outcome) }

  # TODO: Remove usage of Conference.current
  before do
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
    subject { EmailNotifications.welcome(user) }

    let(:user) { FactoryBot.build(:user) }

    it_behaves_like 'standard conference e-mail'

    it { is_expected.to deliver_to(EmailNotifications.send(:format_email, user)) }
    it { is_expected.to have_body_text(/#{user.username}/) }

    context 'with language in pt' do
      before { user.default_locale = 'pt-BR' }

      it { is_expected.to have_subject('[localhost:3000] Cadastro realizado com sucesso') }
    end

    context 'with language in en' do
      before { user.default_locale = 'en' }

      it { is_expected.to have_subject('[localhost:3000] Account registration') }
    end
  end

  describe 'reset password instructions e-mail' do
    subject { EmailNotifications.reset_password_instructions(user, :fake_token) }

    let(:user) { FactoryBot.build(:user) }

    before { user.send(:send_reset_password_instructions) }

    it_behaves_like 'standard conference e-mail'

    it { is_expected.to deliver_to("#{user.full_name} <#{user.email}>") }
    it { is_expected.to have_body_text(%r{/password/edit\?}) }
    it { is_expected.to have_body_text(/fake_token/) }

    context 'with language in pt' do
      before { user.default_locale = 'pt-BR' }

      it { is_expected.to have_subject('[localhost:3000] Recuperação de senha') }
    end

    context 'with language in en' do
      before { user.default_locale = 'en' }

      it { is_expected.to have_subject('[localhost:3000] Password reset') }
    end
  end

  describe 'session submission e-mail' do
    subject { EmailNotifications.session_submitted(session) }

    let(:user) { FactoryBot.build(:user) }
    let(:session) { FactoryBot.build(:session, author: user) }

    it_behaves_like 'standard conference e-mail'

    it { is_expected.to have_body_text(/#{session.title}/) }
    it { is_expected.to have_body_text(%r{/sessions/#{session.to_param}}) }

    context 'with language in pt' do
      before { user.default_locale = 'pt-BR' }

      it { is_expected.to have_subject("[localhost:3000] Proposta de sessão submetida para #{conference.name}") }
      it { is_expected.to have_body_text(/#{I18n.l(conference.submissions_deadline.to_date, format: :long, locale: :'pt-BR')}/) }
    end

    context 'with language in en' do
      before { user.default_locale = 'en' }

      it { is_expected.to have_subject("[localhost:3000] #{conference.name} session proposal submitted") }
      it { is_expected.to have_body_text(/#{I18n.l(conference.submissions_deadline.to_date, format: :long, locale: :en)}/) }
    end

    context 'with single author' do
      let(:session) { FactoryBot.build(:session, author: user) }

      it { is_expected.to deliver_to(EmailNotifications.send(:format_email, user)) }
      it { is_expected.to have_body_text(/#{session.author.full_name},/) }
    end

    context 'with second author' do
      let(:session) { FactoryBot.build(:session, second_author: user) }

      it { is_expected.to deliver_to(EmailNotifications.send(:format_email, session.author), EmailNotifications.send(:format_email, user)) }
      it { is_expected.to have_body_text(/#{session.author.full_name} & #{user.full_name},/) }
    end
  end

  describe 'comment submission e-mail' do
    subject(:notification) { EmailNotifications.comment_submitted(session, comment) }

    let(:user) { FactoryBot.build(:user) }
    let(:session) { FactoryBot.build(:session, author: user) }
    let(:comment) { FactoryBot.build(:comment, commentable: session) }

    it_behaves_like 'standard conference e-mail'

    it { is_expected.to have_body_text(/#{session.title}/) }
    it { is_expected.to have_body_text(%r{/sessions/#{session.to_param}.*#comments}) }
    it { is_expected.to have_body_text(/#{comment.comment}/) }

    context 'with language in pt' do
      before { user.default_locale = 'pt-BR' }

      it { is_expected.to have_subject("[localhost:3000] Novo comentário para a sessão '#{session.title}'") }
    end

    context 'with language in en' do
      before { user.default_locale = 'en' }

      it { is_expected.to have_subject("[localhost:3000] New comment for session '#{session.title}'") }
    end

    context 'with single author' do
      let(:session) { FactoryBot.build(:session, author: user) }

      it { is_expected.to bcc_to(user.email) }
    end

    context 'with second author' do
      let(:session) { FactoryBot.build(:session, second_author: user) }

      it { is_expected.to bcc_to(session.author.email, user.email) }
    end

    context 'with commenters' do
      let(:another_user) { FactoryBot.build(:user, email: 'another.user@provider.com') }
      let(:another_comment) { FactoryBot.build(:comment, commentable: session, user: another_user) }

      it 'is sent to sessions commenters and authors' do
        session.expects(:comments).returns([stub(user: another_user)])
        EmailNotifications.comment_submitted(session, comment)
        expect(notification).to bcc_to(session.author.email, another_user.email)
      end
    end
  end

  describe 'early review submission e-mail' do
    subject { EmailNotifications.early_review_submitted(session) }

    let(:user) { FactoryBot.build(:user) }
    let(:session) { FactoryBot.build(:session, author: user) }

    it_behaves_like 'standard conference e-mail'

    it { is_expected.to have_body_text(/#{session.title}/) }
    it { is_expected.to have_body_text(%r{/sessions/#{session.to_param}/reviews.*early}) }

    context 'with language in pt' do
      before { user.default_locale = 'pt-BR' }

      it { is_expected.to have_subject("[localhost:3000] Pré-avaliação da sua sessão '#{session.title}'") }
    end

    context 'with language in en' do
      before { user.default_locale = 'en' }

      it { is_expected.to have_subject("[localhost:3000] Early review submitted for your session '#{session.title}'") }
    end

    context 'with single author' do
      let(:session) { FactoryBot.build(:session, author: user) }

      it { is_expected.to deliver_to(EmailNotifications.send(:format_email, user)) }
      it { is_expected.to have_body_text(/#{session.author.full_name},/) }
    end

    context 'with second author' do
      let(:session) { FactoryBot.build(:session, second_author: user) }

      it { is_expected.to deliver_to(EmailNotifications.send(:format_email, session.author), EmailNotifications.send(:format_email, user)) }
      it { is_expected.to have_body_text(/#{session.author.full_name} & #{user.full_name},/) }
    end
  end

  describe 'reviewer invitation e-mail' do
    subject { EmailNotifications.reviewer_invitation(reviewer) }

    let(:user) { FactoryBot.build(:user) }
    let(:reviewer) { FactoryBot.build(:reviewer, user: user, id: 3) }

    it_behaves_like 'standard conference e-mail'

    it { is_expected.to deliver_to(EmailNotifications.send(:format_email, user)) }
    it { is_expected.to have_body_text(%r{/reviewers/3/accept}) }
    it { is_expected.to have_body_text(%r{/reviewers/3/reject}) }

    context 'with language in pt' do
      before { user.default_locale = 'pt-BR' }

      it { is_expected.to have_subject("[localhost:3000] Convite para integrar a equipe de revisores da #{conference.name}") }
    end

    context 'with language in en' do
      before { user.default_locale = 'en' }

      it { is_expected.to have_subject("[localhost:3000] Invitation to be part of #{conference.name} review committee") }
    end
  end

  describe 'notification of acceptance e-mail' do
    subject(:notification) { EmailNotifications.notification_of_acceptance(session) }

    let(:user) { FactoryBot.build(:author) }
    let(:session) { FactoryBot.build(:session, state: 'in_review', author: user) }

    it 'is not sent if session has no decision' do
      expect { notification.deliver_now }.to(
        raise_error("Notification can't be sent before decision has been made")
      )
    end

    context 'with review decision' do
      before { session.review_decision = FactoryBot.build(:review_decision, outcome: accept_outcome) }

      it_behaves_like 'standard conference e-mail'

      it { is_expected.to have_body_text(/#{session.title}/) }
      it { is_expected.to have_body_text(%r{/sessions/#{session.to_param}/confirm}) }
      it { is_expected.to have_body_text(%r{/sessions/#{session.to_param}/withdraw}) }

      context 'with language in pt' do
        before { user.default_locale = 'pt-BR' }

        it { is_expected.to have_subject("[localhost:3000] Comunicado do Comitê de Programa da #{conference.name}") }
      end

      context 'with language in en' do
        before { user.default_locale = 'en' }

        it { is_expected.to have_subject("[localhost:3000] Notification from the Program Committee of #{conference.name}") }
      end

      context 'with single author' do
        it { is_expected.to deliver_to(EmailNotifications.send(:format_email, session.author)) }
        it { is_expected.to have_body_text(/#{session.author.full_name}/) }
      end

      context 'with second author' do
        let(:session) { FactoryBot.build(:session, state: 'in_review', second_author: user) }

        before { session.review_decision = FactoryBot.build(:review_decision, outcome: accept_outcome) }

        it { is_expected.to deliver_to(EmailNotifications.send(:format_email, session.author), EmailNotifications.send(:format_email, user)) }
        it { is_expected.to have_body_text(/#{session.author.full_name} & #{user.full_name}/) }
      end
    end
  end

  describe 'notification of rejection e-mail' do
    subject(:notification) { EmailNotifications.notification_of_acceptance(session) }

    let(:user) { FactoryBot.build(:author) }
    let(:session) { FactoryBot.build(:session, state: 'in_review', author: user) }

    it 'is not sent if session has no decision' do
      expect { notification.deliver_now }.to(
        raise_error("Notification can't be sent before decision has been made")
      )
    end

    context 'with review decision of rejection' do
      before { session.review_decision = FactoryBot.build(:review_decision, outcome: reject_outcome) }

      it_behaves_like 'standard conference e-mail'

      it { is_expected.to have_body_text(/#{session.title}/) }
      it { is_expected.to have_body_text(%r{/sessions/#{session.to_param}}) }

      context 'with language in pt' do
        before { user.default_locale = 'pt-BR' }

        it { is_expected.to have_subject("[localhost:3000] Comunicado do Comitê de Programa da #{conference.name}") }
      end

      context 'with language in en' do
        before { user.default_locale = 'en' }

        it { is_expected.to have_subject("[localhost:3000] Notification from the Program Committee of #{conference.name}") }
      end

      context 'with single author' do
        it { is_expected.to deliver_to(EmailNotifications.send(:format_email, session.author)) }
        it { is_expected.to have_body_text(/#{session.author.full_name}/) }
      end

      context 'with second author' do
        let(:session) { FactoryBot.build(:session, state: 'in_review', second_author: user) }

        before { session.review_decision = FactoryBot.build(:review_decision, outcome: reject_outcome) }

        it { is_expected.to deliver_to(EmailNotifications.send(:format_email, session.author), EmailNotifications.send(:format_email, user)) }
        it { is_expected.to have_body_text(/#{session.author.full_name} & #{user.full_name}/) }
      end
    end

    context 'with review decision of backup' do
      before { session.review_decision = FactoryBot.build(:review_decision, outcome: backup_outcome) }

      it_behaves_like 'standard conference e-mail'

      it { is_expected.to have_body_text(/#{session.title}/) }
      it { is_expected.to have_body_text(%r{/sessions/#{session.to_param}}) }

      context 'with language in pt' do
        before { user.default_locale = 'pt-BR' }

        it { is_expected.to have_subject("[localhost:3000] Comunicado do Comitê de Programa da #{conference.name}") }
      end

      context 'with language in en' do
        before { user.default_locale = 'en' }

        it { is_expected.to have_subject("[localhost:3000] Notification from the Program Committee of #{conference.name}") }
      end

      context 'with single author' do
        it { is_expected.to deliver_to(EmailNotifications.send(:format_email, session.author)) }
        it { is_expected.to have_body_text(/#{session.author.full_name}/) }
      end

      context 'with second author' do
        let(:session) { FactoryBot.build(:session, state: 'in_review', second_author: user) }

        before { session.review_decision = FactoryBot.build(:review_decision, outcome: backup_outcome) }

        it { is_expected.to deliver_to(EmailNotifications.send(:format_email, session.author), EmailNotifications.send(:format_email, user)) }
        it { is_expected.to have_body_text(/#{session.author.full_name} & #{user.full_name}/) }
      end
    end
  end

  describe 'review feedback request' do
    subject { EmailNotifications.review_feedback_request(user) }

    let(:user) { FactoryBot.build(:author) }

    it_behaves_like 'standard conference e-mail'

    context 'with language in pt' do
      before { user.default_locale = 'pt-BR' }

      it { is_expected.to have_subject("[localhost:3000] Pedido de feedback sobre as avaliações de suas sessões na #{conference.name}") }
    end

    context 'with language in en' do
      before { user.default_locale = 'en' }

      it { is_expected.to have_subject("[localhost:3000] Feedback request for the reviews of your sessions for #{conference.name}") }
    end

    context 'with single author' do
      it { is_expected.to deliver_to(EmailNotifications.send(:format_email, user)) }
      it { is_expected.to have_body_text(/#{user.full_name},/) }
    end
  end
end
