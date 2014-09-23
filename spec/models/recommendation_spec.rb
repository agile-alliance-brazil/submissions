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
end
