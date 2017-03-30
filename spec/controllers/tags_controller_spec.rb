# encoding: UTF-8
# frozen_string_literal: true

require 'spec_helper'

describe TagsController, type: :controller do
  describe '#index', 'with json format' do
    before do
      xhr :get, :index, format: :json, term: 'sof'
    end

    subject { response }

    its(:content_type) { should == 'application/json' }
  end
end
