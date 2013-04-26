# encoding: utf-8
shared_examples_for "ActiveModel" do
  require 'test/unit/assertions'
  require 'active_model/lint'
  include Test::Unit::Assertions
  include ActiveModel::Lint::Tests

  # to_s is to support ruby-1.9
  ActiveModel::Lint::Tests.public_instance_methods.map{|m| m.to_s}.grep(/^test/).each do |m|
    example m.gsub('_',' ') do
      send m
    end
  end

  let(:model) { subject }
end
