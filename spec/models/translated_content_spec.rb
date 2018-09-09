# frozen_string_literal: true

require 'spec_helper'

describe TranslatedContent, type: :model do
  subject { FactoryBot.build :translated_content }

  describe 'validations' do
    it { is_expected.to validate_presence_of :title }
    it { is_expected.to validate_presence_of :content }
    it { is_expected.to validate_presence_of :language }
    it { is_expected.to validate_uniqueness_of(:language).scoped_to(%i[model_id model_type]) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:model) }
  end

  context 'deprecated methods' do
    it 'assigns description to content' do
      subject.description = 'Just testing'

      expect(subject.content).to eq('Just testing')
    end
    it 'returns content if asking for description' do
      subject.content = 'Just testing'

      expect(subject.description).to eq('Just testing')
    end
  end
end
