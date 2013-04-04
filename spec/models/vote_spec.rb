# encoding: UTF-8
require 'spec_helper'

describe Vote do
  context "protect from mass assignment" do
    it { should allow_mass_assignment_of :user_id }
    it { should allow_mass_assignment_of :session_id }
    it { should allow_mass_assignment_of :conference_id }

    it { should_not allow_mass_assignment_of :id }
  end

  context "validations" do
    it { should validate_presence_of :session_id }
    it { should validate_presence_of :user_id }
    it { should validate_presence_of :conference_id }

    should_validate_existence_of :conference, :session, :user

    context "uniqueness" do
      before { FactoryGirl.create(:vote) }
      it { should validate_uniqueness_of(:user_id).scoped_to(:session_id, :conference_id) }
    end

    context "session" do
      it "should match the conference" do
        vote = FactoryGirl.build(:vote, :conference => Conference.first)
        vote.should_not be_valid
        vote.errors[:session_id].should include(I18n.t("errors.messages.invalid"))
      end
    end

    context "user" do
      let(:second_author) { FactoryGirl.create(:author) }
      let(:session) { FactoryGirl.create(:session) }
      let(:vote) { FactoryGirl.build(:vote, :session => session) }

      it "should not be author for voted session" do
        vote.user = session.author
        vote.should_not be_valid
        vote.errors[:user_id].should include(I18n.t("errors.messages.invalid"))
      end

      it "should not be second author for voted session" do
        session.second_author = second_author
        vote.user = second_author
        vote.should_not be_valid
        vote.errors[:user_id].should include(I18n.t("errors.messages.invalid"))
      end
    end

    context "limit" do
      let(:user) { FactoryGirl.create(:user) }
      before { FactoryGirl.create_list(:vote, Vote::VOTE_LIMIT, :user => user) }

      it "should only allow #{Vote::VOTE_LIMIT} votes for given conference" do
        vote = FactoryGirl.build(:vote, :user => user)
        vote.should_not be_valid
        vote.errors[:base].should include(I18n.t("activerecord.errors.models.vote.limit_reached", :count => Vote::VOTE_LIMIT))
      end
    end
  end

  context "associations" do
    it { should belong_to :user }
    it { should belong_to :session }
    it { should belong_to :conference }
  end
end
