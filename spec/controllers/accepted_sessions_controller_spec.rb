# frozen_string_literal: true

require 'spec_helper'

describe AcceptedSessionsController, type: :controller do
  describe '#index' do
    context 'csv' do
      let(:conference) { FactoryBot.create(:conference) }

      context 'unauthorized user' do
        before do
          @user = FactoryBot.build(:user)
          @user.add_role('organizer')
          controller.stubs(:current_user).returns(@user)
        end

        it 'returns 403 status' do
          get :index, year: conference.year, format: :csv

          expect(response.status).to eq(403)
        end
        it 'says unauthorized' do
          get :index, year: conference.year, format: :csv

          expect(response.body).to eq('Unauthorized')
        end
      end

      context 'authorized user' do
        before do
          controller.stubs(:current_ability).returns(stub(can?: true))
        end

        it 'generates CSV from accepted sessions' do
          session = FactoryBot.create(:session, state: 'accepted', conference: conference)

          get :index, year: conference.year, format: :csv

          csv = <<~CSV
            Session id,Session title,Session Type,Author,Email
            #{session.id},#{session.title},#{I18n.t(session.session_type.title)},#{session.author.full_name},#{session.author.email}
          CSV
          expect(response.body).to eq(csv)
        end
      end
    end
  end
end
