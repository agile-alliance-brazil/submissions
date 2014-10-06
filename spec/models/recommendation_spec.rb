# encoding: UTF-8
require 'spec_helper'

describe Recommendation, type: :model do
  context "validations" do
    it { should validate_presence_of :title }
  end

  Recommendation.all_titles.each do |title|
    it "should determine if it's #{title}" do
      recommendation = FactoryGirl.build(:recommendation, title: "recommendation.#{title}.title")
      expect(recommendation.send(:"#{title}?")).to be true
      recommendation = FactoryGirl.build(:recommendation, title: 'recommendation.other.title')
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
end
