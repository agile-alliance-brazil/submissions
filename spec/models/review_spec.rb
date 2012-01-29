require 'spec_helper'

describe Review do
  context "protect from mass assignment" do
    should_allow_mass_assignment_of :author_agile_xp_rating_id
    should_allow_mass_assignment_of :author_proposal_xp_rating_id

    should_allow_mass_assignment_of :proposal_track
    should_allow_mass_assignment_of :proposal_level
    should_allow_mass_assignment_of :proposal_type
    should_allow_mass_assignment_of :proposal_duration
    should_allow_mass_assignment_of :proposal_limit
    should_allow_mass_assignment_of :proposal_abstract

    should_allow_mass_assignment_of :proposal_quality_rating_id
    should_allow_mass_assignment_of :proposal_relevance_rating_id

    should_allow_mass_assignment_of :recommendation_id
    should_allow_mass_assignment_of :justification

    should_allow_mass_assignment_of :reviewer_confidence_rating_id
    should_allow_mass_assignment_of :comments_to_organizers
    should_allow_mass_assignment_of :comments_to_authors

    should_allow_mass_assignment_of :session_id
    should_allow_mass_assignment_of :reviewer_id

    should_not_allow_mass_assignment_of :id
  end

  it_should_trim_attributes Review, :comments_to_organizers, :comments_to_authors, :justification

  context "associations" do
    should_belong_to :reviewer, :class_name => 'User'
    should_belong_to :session, :counter_cache => true
    should_belong_to :recommendation

    should_belong_to :author_agile_xp_rating, :class_name => "Rating"
    should_belong_to :author_proposal_xp_rating, :class_name => "Rating"
    should_belong_to :proposal_quality_rating, :class_name => "Rating"
    should_belong_to :proposal_relevance_rating, :class_name => "Rating"
    should_belong_to :reviewer_confidence_rating, :class_name => "Rating"
  end

  it "should determine if it's strong accept" do
    strong = Recommendation.new(:title => 'recommendation.strong_accept.title')
    review = Factory(:review)
    review.should_not be_strong_accept
    review.recommendation = strong
    review.should be_strong_accept
  end

  context "validations" do
    should_validate_presence_of :author_agile_xp_rating_id
    should_validate_presence_of :author_proposal_xp_rating_id

    should_validate_inclusion_of :proposal_track, :in => [true, false]
    should_validate_inclusion_of :proposal_level, :in => [true, false]
    should_validate_inclusion_of :proposal_type, :in => [true, false]
    should_validate_inclusion_of :proposal_duration, :in => [true, false]
    should_validate_inclusion_of :proposal_limit, :in => [true, false]
    should_validate_inclusion_of :proposal_abstract, :in => [true, false]

    should_validate_presence_of :proposal_quality_rating_id
    should_validate_presence_of :proposal_relevance_rating_id

    should_validate_presence_of :recommendation_id

    should_validate_presence_of :reviewer_confidence_rating_id

    should_validate_presence_of :reviewer_id
    should_validate_presence_of :session_id

    should_validate_length_of :comments_to_authors, :minimum => 150

    before { Factory(:review) }
    should_validate_uniqueness_of :reviewer_id, :scope => :session_id

    context "strong acceptance" do
      before(:each) do
        @review = Factory(:review)
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
        @review = Factory(:review)
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
        @review = Factory(:review)
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
        @review = Factory(:review)
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
      review = Factory.build(:review)
      review.save
      review.session.should be_in_review
    end

    it "should not set session in review if validation failed" do
      review = Factory.build(:review, :reviewer_id => nil)
      review.save
      review.session.should be_created
    end
  end

end