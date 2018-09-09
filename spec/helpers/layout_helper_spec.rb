# frozen_string_literal: true

describe ReviewersHelper, type: :helper do
  describe '#ideal_reviews_burn' do
    let(:conference) { FactoryBot.create :conference_in_review_time }

    it 'calls the proper method in the conference object' do
      conference.expects(:ideal_reviews_burn).once
      helper.ideal_reviews_burn(conference)
    end
  end

  describe '#actual_reviews_burn' do
    let(:conference) { FactoryBot.create :conference_in_review_time }

    it 'calls the proper method in the conference object' do
      conference.expects(:actual_reviews_burn).once
      helper.actual_reviews_burn(conference)
    end
  end
end
