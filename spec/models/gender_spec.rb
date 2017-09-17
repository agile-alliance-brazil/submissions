# frozen_string_literal: true

require 'spec_helper'

describe Gender, type: :model do
  it 'should provide translated options for select' do
    expect(Gender.options_for_select).to include([I18n.t('gender.male'), 'M'])
    expect(Gender.options_for_select).to include([I18n.t('gender.female'), 'F'])
    expect(Gender.options_for_select.size).to eq(2)
  end

  it 'should provide valid values' do
    expect(Gender.valid_values).to eq(%w[M F])
  end

  it 'should provide title for given value' do
    expect(Gender.title_for('M')).to eq(I18n.t('gender.male'))
    expect(Gender.title_for('F')).to eq(I18n.t('gender.female'))
  end
end
