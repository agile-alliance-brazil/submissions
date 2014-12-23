# encoding: UTF-8
require 'spec_helper'

describe ReviewsController, type: :controller do
  let(:valid_early_review_params) do
    {
      author_agile_xp_rating_id: 1,
      author_proposal_xp_rating_id: 1,
      proposal_track: true,
      proposal_level: true,
      proposal_type: true,
      proposal_duration: true,
      proposal_limit: true,
      proposal_abstract: true,
      proposal_quality_rating_id: 1,
      proposal_relevance_rating_id: 1,
      reviewer_confidence_rating_id: 1,
      comments_to_organizers: 'This is awesome!',
      comments_to_authors: "You're the best!" * 10
    }
  end
  let(:valid_final_review_params) do
    valid_early_review_params.merge(recommendation_id: 1,
      justification: 'This is great!')
  end
  let(:conference) { FactoryGirl.create(:conference) }
  let(:session) { FactoryGirl.create(:session, conference: conference).tap{|s| s.reviewing} }
  let(:reviewer) { FactoryGirl.create(:reviewer, conference: conference)}
  before(:each) do
    sign_in reviewer.user
    disable_authorization

    Conference.stubs(:current).returns(conference)
    conference.stubs(:in_early_review_phase?).returns(false)
  end

  describe "with view rendering", render_views: true do
    render_views
    describe 'collection' do
      before do
        FactoryGirl.create(:early_review, session: session, reviewer: FactoryGirl.create(:reviewer, conference: conference).user)
        FactoryGirl.create(:final_review, session: session, reviewer: FactoryGirl.create(:reviewer, conference: conference).user)
        FactoryGirl.create(:final_review, session: session, reviewer: FactoryGirl.create(:reviewer, conference: conference).user)
        FactoryGirl.create(:final_review, session: session, reviewer: FactoryGirl.create(:reviewer, conference: conference).user)
      end
      it "index early reviews for organizer should work" do
        get :organizer, session_id: session.id, type: 'early'
      end

      it "index final reviews for organizer should work" do
        get :organizer, session_id: session.id
      end

      it "index early reviews for author should work" do
        get :index, session_id: session.id, type: 'early'
      end

      it "index final reviews for author should work" do
        get :index, session_id: session.id
      end
    end

    it "show should work for early review" do
      early_review = FactoryGirl.create(:early_review,
        reviewer: reviewer.user, session: session)

      get :show, id: early_review.id, session_id: session.id

      expect(assigns(:review)).to_not be_nil
    end

    it "show should work for final review" do
      final_review = FactoryGirl.create(:final_review,
        reviewer: reviewer.user, session: session)

      get :show, id: final_review.id, session_id: session.id

      expect(assigns(:review)).to_not be_nil
    end

    it "new should work for early review" do
      conference.expects(:in_early_review_phase?).returns(true)
      get :new, session_id: session.id
    end

    it "show should work for final review" do
      conference.expects(:in_early_review_phase?).returns(false)
      get :new, session_id: session.id
    end
  end

  it_should_require_login_for_actions :index, :show, :new, :create

  it "new action should set reviewer" do
    get :new, session_id: session.id

    expect(assigns(:review).reviewer).to eq(reviewer.user)
  end

  it "create action should render new template when model is invalid" do
    params = valid_early_review_params.except(:comments_to_authors)
    
    post :create, session_id: session.id, final_review: params
    
    expect(response).to render_template(:new)
  end

  it "create action should redirect when final review is valid" do
    conference.expects(:in_early_review_phase?).returns(false)
    params = valid_final_review_params
    
    post :create, session_id: session.id, final_review: params

    expect(assigns(:review)).to_not be_nil
    path = session_review_path(conference, assigns(:session), assigns(:review))
    expect(response).to redirect_to(path)
  end

  it "create action should redirect when early review is valid" do
    conference.stubs(:in_early_review_phase?).returns(true)
    params = valid_early_review_params
    
    post :create, session_id: session.id, early_review: params

    expect(assigns(:review)).to_not be_nil
    path = session_review_path(conference, assigns(:session), assigns(:review))
    expect(response).to redirect_to(path)
  end
end
