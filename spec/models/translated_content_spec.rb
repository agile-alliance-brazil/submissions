# encoding: UTF-8
# frozen_string_literal: true
require 'spec_helper'

describe TranslatedContent, type: :model do
  subject { FactoryGirl.build :translated_content }

  context 'validations' do
    it { should validate_presence_of :title }
    it { should validate_presence_of :content }
    it { should validate_presence_of :language }
    it { should validate_uniqueness_of(:language).scoped_to(%i(model_id model_type)) }
  end

  context 'associations' do
    it { should belong_to(:model) }
  end

  context 'deprecated methods' do
    it 'should assign description to content' do
      subject.description = 'Just testing'

      expect(subject.content).to eq('Just testing')
    end
    it 'should return content if asking for description' do
      subject.content = 'Just testing'

      expect(subject.description).to eq('Just testing')
    end
  end
end
