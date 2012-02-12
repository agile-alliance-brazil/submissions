# encoding: UTF-8
require 'spec_helper'

describe RegisteredGroupsHelper do
  describe "#registration_group_status_options" do
    it "should return status options for filtering" do
      helper.registration_group_status_options.should include(['Todos', nil])
      helper.registration_group_status_options.should include(['Incompleto', 'incomplete'])
      helper.registration_group_status_options.should include(['Pendente', 'complete'])
      helper.registration_group_status_options.should include(['Pagamento efetuado', 'paid'])
      helper.registration_group_status_options.should include(['Confirmado', 'confirmed'])
      helper.registration_group_status_options.should have(5).items
    end
  end
end
