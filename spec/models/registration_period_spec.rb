require 'spec_helper'

describe RegistrationPeriod do
  %w(pre_registered early_bird regular last_minute).each do |period|
    describe "#{period} period" do
      it "start date" do
        RegistrationPeriod.send(period.to_sym).should     === RegistrationPeriod.const_get("#{period.upcase}_START") + 1.second
        RegistrationPeriod.send(period.to_sym).should     === RegistrationPeriod.const_get("#{period.upcase}_START")
        RegistrationPeriod.send(period.to_sym).should_not === RegistrationPeriod.const_get("#{period.upcase}_START") - 1.second
      end

      it "end date" do
        RegistrationPeriod.send(period.to_sym).should     === RegistrationPeriod.const_get("#{period.upcase}_END") - 1.second
        RegistrationPeriod.send(period.to_sym).should     === RegistrationPeriod.const_get("#{period.upcase}_END")
        RegistrationPeriod.send(period.to_sym).should_not === RegistrationPeriod.const_get("#{period.upcase}_END") + 1.second
      end
    end
  end
end
