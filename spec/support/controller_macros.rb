# encoding: UTF-8
module ControllerMacros
  extend ActiveSupport::Concern

  module ClassMethods
    def it_should_require_login_for_actions(*actions)
      actions.each do |action|
        it "should require login for action #{action}" do
          before_filters = controller.class._process_action_callbacks.find_all {|x| x.kind == :before}.map(&:filter)
          expect(before_filters).to include(:authenticate_user!)
        end
      end

    end

    def it_should_require_logout_for_actions(*actions)
      actions.each do |action|
        it "should require logout for action #{action}" do
          before_filters = controller.class._process_action_callbacks.find_all {|x| x.kind == :before}.map(&:filter)
          expect(before_filters).to include(:logout_required)
        end
      end
    end

    def it_should_behave_like_a_devise_controller
      before(:each) do
        request.env["devise.mapping"] = Devise.mappings[:user]
      end
    end
  end

end
