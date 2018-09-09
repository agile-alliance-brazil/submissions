# frozen_string_literal: true

require 'spec_helper'

describe Recommendation, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
  end

  Recommendation.all_names.each do |title|
    it "should determine if it's #{title}" do
      recommendation = FactoryBot.build(:recommendation, name: title)
      expect(recommendation.send(:"#{title}?")).to be true
      recommendation = FactoryBot.build(:recommendation, name: 'other')
      expect(recommendation.send(:"#{title}?")).to be false
    end
  end

  describe 'title_for' do
    it 'prepends recommendation. to title' do
      expect(Recommendation.title_for('example')).to start_with('recommendation.')
    end
    it 'postpends title. to title' do
      expect(Recommendation.title_for('example')).to end_with('.title')
    end
    it 'includes title between preset text' do
      expect(Recommendation.title_for('example')).to eq('recommendation.example.title')
    end
  end

  describe 'title' do
    subject(:recommendation) { FactoryBot.build(:recommendation) }

    it 'returns the translation text' do
      expect(recommendation.title).to eq(Recommendation.title_for(recommendation.name))
    end
  end
end
