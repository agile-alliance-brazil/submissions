# encoding: UTF-8
require 'spec_helper'

describe RegisteredAttendeesHelper do
  describe "#attendee_status_options" do
    it "should return status options for filtering" do
      helper.attendee_status_options.should include(['Todos', nil])
      helper.attendee_status_options.should include(['Pendente', 'pending'])
      helper.attendee_status_options.should include(['Pagamento efetuado', 'paid'])
      helper.attendee_status_options.should include(['Confirmado', 'confirmed'])
      helper.attendee_status_options.should have(4).items
    end
  end
end
