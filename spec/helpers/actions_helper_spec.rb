require 'spec_helper'

describe ActionsHelper, type: :helper do
  describe 'user section' do
    context 'normal user logged in' do
      subject do
        helper.user_section_for(FactoryGirl.build(:user)).actions
      end

      it 'should be able to show user profile' do
        pending('need to figure out how to set up abilities to work in this test')

        subject[0][:name].should == t('actions.profile')
      end

      it 'should be able to edit user profile' do
        pending('need to figure out how to set up abilities to work in this test')

        subject[1][:name].should == t('actions.edit_profile')
      end

      it 'should be able to change password' do
        pending('need to figure out how to set up abilities to work in this test')

        subject[2][:name].should == t('actions.change_password')
      end

      it 'should be able to logout' do
        pending('need to figure out how to set up abilities to work in this test')

        subject[3][:name].should == 'Logout'
      end
    end
  end
end
