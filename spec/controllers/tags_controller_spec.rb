# encoding: UTF-8
require 'spec_helper'
 
describe TagsController do
  describe "#index", "with javascript format" do
    before do
      get :index, :format => :js, :term => 'sof'
    end
      
    it { should respond_with_content_type(:js) }
  end
end
