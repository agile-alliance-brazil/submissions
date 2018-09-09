# frozen_string_literal: true

require 'spec_helper'

describe SessionType, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of :conference }
    # TODO: Validations of languages
  end

  describe 'associations' do
    it { is_expected.to have_many :sessions }
    it { is_expected.to belong_to :conference }
    it { is_expected.to have_many :translated_contents }
  end

  context 'types' do
    before do
      @tutorial = FactoryBot.create(:session_type, title: 'session_types.tutorial.title')
      @lightning_talk = FactoryBot.create(:session_type, title: 'session_types.lightning_talk.title')

      SessionType.stubs(:select).with(:title).returns(SessionType)
      SessionType.stubs(:uniq).returns([@tutorial, @lightning_talk])
    end

    it 'detects all titles' do
      expect(SessionType.all_titles).to eq(%w[tutorial lightning_talk])
    end

    it 'determines if it is tutorial' do
      session_type = FactoryBot.build(:session_type, title: 'session_types.tutorial.title')
      expect(session_type.send(:tutorial?)).to be true
      session_type = FactoryBot.build(:session_type, title: 'session_types.other.title')
      expect(session_type.send(:tutorial?)).to be false
    end

    it 'determines if it is lightning talk' do
      session_type = FactoryBot.build(:session_type, title: 'session_types.lightning_talk.title')
      expect(session_type.send(:lightning_talk?)).to be true
      session_type = FactoryBot.build(:session_type, title: 'session_types.other.title')
      expect(session_type.send(:lightning_talk?)).to be false
    end
  end
end
