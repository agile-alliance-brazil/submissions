module ControllerMacros
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def it_should_require_login_for_actions(*actions)
      actions.each do |action|
        it "should require login for action #{action}" do
          controller.should_receive(:logged_in?).and_return(false)
          get action, :id => '1'
          response.should redirect_to(login_url)
        end
      end
      
    end
    
    def it_should_require_logout_for_actions(*actions)
      actions.each do |action|
        it "should require logout for action #{action}" do
          controller.should_receive(:logged_in?).and_return(true)
          request.env["HTTP_REFERER"] = '/some/url'
          get action, :id => '1'
          flash[:error].should_not be_empty
          response.should redirect_to('/some/url')
        end
      end
    end
  end  
  
end