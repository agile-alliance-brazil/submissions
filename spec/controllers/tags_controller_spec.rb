# frozen_string_literal: true

require 'spec_helper'

describe TagsController, type: :controller do
  describe '#index', 'with json format' do
    subject { response }

    before do
      xhr :get, :index, format: :json, term: 'sof'
    end

    its(:content_type) { is_expected.to eq('application/json') }
  end
end
