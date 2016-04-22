# encoding: utf-8
shared_examples_for "ActiveModel" do
  include ActiveModel::Lint::Tests

  # to_s is to support ruby-1.9
  ActiveModel::Lint::Tests.public_instance_methods.
    map(&:to_s).grep(/\Atest/).each do |m|
    example m.gsub('_',' ') do
      send m
    end
  end

  let(:model) { subject }
end
