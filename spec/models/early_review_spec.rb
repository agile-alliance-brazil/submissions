# encoding: UTF-8
require 'spec_helper'

describe EarlyReview do
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

    it { should allow_mass_assignment_of :reviewer_confidence_rating_id }
    it { should allow_mass_assignment_of :comments_to_organizers }
    it { should allow_mass_assignment_of :comments_to_authors }

    it { should allow_mass_assignment_of :session_id }
    it { should allow_mass_assignment_of :reviewer_id }

    it { should_not allow_mass_assignment_of :id }
  end

  it_should_trim_attributes EarlyReview, :comments_to_organizers, :comments_to_authors

  context "associations" do
    it { should belong_to :reviewer }
    it { should belong_to :session }

    it { should belong_to :author_agile_xp_rating }
    it { should belong_to :author_proposal_xp_rating }
    it { should belong_to :proposal_quality_rating }
    it { should belong_to :proposal_relevance_rating }
    it { should belong_to :reviewer_confidence_rating }
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

    it { should validate_presence_of :reviewer_confidence_rating_id }

    it { should validate_presence_of :reviewer_id }
    it { should validate_presence_of :session_id }

    it { should ensure_length_of(:comments_to_authors).is_at_least(150) }

    context "uniqueness" do
      before { FactoryGirl.create(:early_review) }
      it { should validate_uniqueness_of(:reviewer_id).scoped_to(:session_id) }
    end
  end

  context "notifications" do
    it "should notify session author(s) after creation" do
      review = FactoryGirl.build(:early_review)
      EarlyReview.send(:public, :notify)

      EmailNotifications.expects(:send_early_review_submitted).with(review.session)

      review.notify
    end
  end
end
