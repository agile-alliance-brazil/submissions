require 'spec/spec_helper'
 
describe ConfirmSessionsController do
  integrate_views

  it_should_require_login_for_actions :show, :update

  before(:each) do
    @user = Factory(:user)
    @session = Factory(:session, :author => @user)
    @session.reviewing
    Factory(:review_decision, :session => @session)
    @session.tentatively_accept
    Session.stubs(:find).returns(@session)
    activate_authlogic    
    UserSession.create(@user)
    Time.zone.stubs(:now).returns(Time.zone.local(2010, 1, 1))
  end

  it "show action should render show template" do
    get :show, :session_id => @session.id
    response.should render_template(:show)
  end
  
  it "update action should render show template when model is invalid" do
    # +stubs(:valid?).returns(false)+ doesn't work here because
    # inherited_resources does +obj.errors.empty?+ to determine
    # if validation failed
    put :update, :session_id => @session.id, :session => {:author_agreement => false}
    response.should render_template(:show)
  end

  it "update action should redirect when model is valid" do
    Session.any_instance.stubs(:valid?).returns(true)
    put :update, :session_id => @session.id, :session => {}
    response.should redirect_to(user_my_sessions_path(@user))
  end
  
  context "authorization" do
    describe "#show should allow access if:" do
      it "- user is first author" do
        get :show, :session_id => @session.id
        flash[:error].should be_blank

        @session.stubs(:author).returns(@another_user)
        get :show, :session_id => @session.id
        flash[:error].should == "Você não está autorizado a acessar esta página"

        @session.stubs(:second_author).returns(@user)
        get :show, :session_id => @session.id
        flash[:error].should == "Você não está autorizado a acessar esta página"
      end
    
      it "- session is pending confirmation" do
        get :show, :session_id => @session.id
        flash[:error].should be_blank

        @session.stubs(:pending_confirmation?).returns(false)
        get :show, :session_id => @session.id
        flash[:error].should == "Você não está autorizado a acessar esta página"
      end
    
      it "- session has a review" do
        get :show, :session_id => @session.id
        flash[:error].should be_blank

        @session.stubs(:review_decision).returns(nil)
        get :show, :session_id => @session.id
        flash[:error].should == "Você não está autorizado a acessar esta página"
      end
    
      it "- before deadline of 17/5/2010" do
        Time.zone.expects(:now).at_least_once.returns(Time.zone.local(2010, 5, 17, 23, 59, 58))
        get :show, :session_id => @session.id
        flash[:error].should be_blank
      end
    
      it "- after deadline can't confirm" do
        Time.zone.expects(:now).at_least_once.returns(Time.zone.local(2010, 5, 18, 0, 0, 0))
        get :show, :session_id => @session.id
        flash[:error].should == "Você não está autorizado a acessar esta página"
      end
    end

    describe "#update should allow access if:" do
      it "- user is first author" do
        put :update, :session_id => @session.id
        flash[:error].should be_blank

        @session.stubs(:author).returns(@another_user)
        put :update, :session_id => @session.id
        flash[:error].should == "Você não está autorizado a acessar esta página"

        @session.stubs(:second_author).returns(@user)
        put :update, :session_id => @session.id
        flash[:error].should == "Você não está autorizado a acessar esta página"
      end
    
      it "- session is pending confirmation" do
        put :update, :session_id => @session.id
        flash[:error].should be_blank

        @session.stubs(:pending_confirmation?).returns(false)
        put :update, :session_id => @session.id
        flash[:error].should == "Você não está autorizado a acessar esta página"
      end
    
      it "- session has a review" do
        put :update, :session_id => @session.id
        flash[:error].should be_blank

        @session.stubs(:review_decision).returns(nil)
        put :update, :session_id => @session.id
        flash[:error].should == "Você não está autorizado a acessar esta página"
      end
    
      it "- before deadline of 17/5/2010" do
        Time.zone.expects(:now).at_least_once.returns(Time.zone.local(2010, 5, 17, 23, 59, 58))
        put :update, :session_id => @session.id
        flash[:error].should be_blank
      end
    
      it "- after deadline can't confirm" do
        Time.zone.expects(:now).at_least_once.returns(Time.zone.local(2010, 5, 18, 0, 0, 0))
        put :update, :session_id => @session.id
        flash[:error].should == "Você não está autorizado a acessar esta página"
      end
    end
  end
  
end
