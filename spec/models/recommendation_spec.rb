# encoding: UTF-8
# frozen_string_literal: true

require 'spec_helper'

describe Recommendation, type: :model do
  context 'validations' do
    it { should validate_presence_of :name }
  end

  Recommendation.all_names.each do |title|
    it "should determine if it's #{title}" do
      recommendation = FactoryGirl.build(:recommendation, name: title)
      expect(recommendation.send(:"#{title}?")).to be true
      recommendation = FactoryGirl.build(:recommendation, name: 'other')
      expect(recommendation.send(:"#{title}?")).to be false
    end
  end

  context 'title_for' do
    it 'should prepend recommendation. to title' do
      expect(Recommendation.title_for('example')).to start_with('recommendation.')
    end
    it 'should postpend title. to title' do
      expect(Recommendation.title_for('example')).to end_with('.title')
    end
    it 'should include title between preset text' do
      expect(Recommendation.title_for('example')).to eq('recommendation.example.title')
    end
  end

  context 'title' do
    before(:each) do
      @recommendation = FactoryGirl.build(:recommendation)
    end
    it 'should return the translation text' do
      expect(@recommendation.title).to eq(Recommendation.title_for(@recommendation.name))
    end
  end
end
