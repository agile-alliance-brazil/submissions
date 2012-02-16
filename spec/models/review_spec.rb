# encoding: UTF-8
require 'spec_helper'

describe Review do
  context "protect from mass assignment" do
    it { should allow_mass_assignment_of :author_agile_xp_rating_id }
    it { should allow_mass_assignment_of :author_proposal_xp_rating_id }

    it { should allow_mass_assignment_of :proposal_track }
    it { should allow_mass_assignment_of :proposal_level }
    it { should allow_mass_assignment_of :proposal_type }
    it { should allow_mass_assignment_of :proposal_duration }
    it { should allow_mass_assignment_of :proposal_limit }
    it { should allow_mass_assignment_of :proposal_abstract }

    it { should allow_mass_assignment_of :proposal_quality_rating_id }
    it { should allow_mass_assignment_of :proposal_relevance_rating_id }

    it { should allow_mass_assignment_of :recommendation_id }
    it { should allow_mass_assignment_of :justification }

    it { should allow_mass_assignment_of :reviewer_confidence_rating_id }
    it { should allow_mass_assignment_of :comments_to_organizers }
    it { should allow_mass_assignment_of :comments_to_authors }

    it { should allow_mass_assignment_of :session_id }
    it { should allow_mass_assignment_of :reviewer_id }

    it { should_not allow_mass_assignment_of :id }
  end

  it_should_trim_attributes Review, :comments_to_organizers, :comments_to_authors, :justification

  context "associations" do
    it { should belong_to :reviewer }
    it { should belong_to :session }
    it { should belong_to :recommendation }

    it { should belong_to :author_agile_xp_rating }
    it { should belong_to :author_proposal_xp_rating }
    it { should belong_to :proposal_quality_rating }
    it { should belong_to :proposal_relevance_rating }
    it { should belong_to :reviewer_confidence_rating }
  end

  it "should determine if it's strong accept" do
    strong = Recommendation.new(:title => 'recommendation.strong_accept.title')
    review = FactoryGirl.build(:review)
    review.should_not be_strong_accept
    review.recommendation = strong
    review.should be_strong_accept
  end

  context "validations" do
    it { should validate_presence_of :author_agile_xp_rating_id }
    it { should validate_presence_of :author_proposal_xp_rating_id }

    xit { should validate_inclusion_of :proposal_track, :in => [true, false] }
    xit { should validate_inclusion_of :proposal_level, :in => [true, false] }
    xit { should validate_inclusion_of :proposal_type, :in => [true, false] }
    xit { should validate_inclusion_of :proposal_duration, :in => [true, false] }
    xit { should validate_inclusion_of :proposal_limit, :in => [true, false] }
    xit { should validate_inclusion_of :proposal_abstract, :in => [true, false] }

    it { should validate_presence_of :proposal_quality_rating_id }
    it { should validate_presence_of :proposal_relevance_rating_id }

    it { should validate_presence_of :recommendation_id }

    it { should validate_presence_of :reviewer_confidence_rating_id }

    it { should validate_presence_of :reviewer_id }
    it { should validate_presence_of :session_id }

    it { should ensure_length_of(:comments_to_authors).is_at_least(150) }

    context "uniqueness" do
      before { FactoryGirl.create(:review) }
      it { should validate_uniqueness_of(:reviewer_id).scoped_to(:session_id) }
    end

    context "strong acceptance" do
      before(:each) do
        @review = FactoryGirl.build(:review)
        @review.recommendation.title = "recommendation.strong_accept.title"
      end

      it "should not validate presence of justification" do
        @review.justification = nil
        @review.should be_valid
        @review.justification = "I want to justify that the session rules!"
        @review.should be_valid
      end
    end

    context "weak acceptance" do
      before(:each) do
        @review = FactoryGirl.build(:review)
        @review.recommendation.title = "recommendation.weak_accept.title"
      end

      it "should validate presence of justification" do
        @review.justification = nil
        @review.should_not be_valid
        @review.justification = ""
        @review.should_not be_valid
        @review.justification = "I want to justify that the session is ok."
        @review.should be_valid
      end
    end

    context "weak rejection" do
      before(:each) do
        @review = FactoryGirl.build(:review)
        @review.recommendation.title = "recommendation.weak_reject.title"
      end

      it "should validate presence of justification" do
        @review.justification = nil
        @review.should_not be_valid
        @review.justification = ""
        @review.should_not be_valid
        @review.justification = "I want to justify that the session is not so good..."
        @review.should be_valid
      end
    end

    context "strong rejection" do
      before(:each) do
        @review = FactoryGirl.build(:review)
        @review.recommendation.title = "recommendation.strong_reject.title"
      end

      it "should validate presence of justification" do
        @review.justification = nil
        @review.should_not be_valid
        @review.justification = ""
        @review.should_not be_valid
        @review.justification = "I want to justify that the session sucks a lot..."
        @review.should be_valid
      end
    end
  end

  context "callbacks" do
    it "should set session in review after created" do
      review = FactoryGirl.build(:review)
      review.save
      review.session.should be_in_review
    end

    it "should not set session in review if validation failed" do
      review = FactoryGirl.build(:review, :reviewer_id => nil)
      review.save
      review.session.should be_created
    end
  end

end
