require 'spec/spec_helper'

describe ReviewPublisher do
  before(:each) do
    Session.stubs(:count).returns(0)
    @publisher = ReviewPublisher.new
  end
  
  it "should raise error if there are sessions not reviewed" do
    Session.expects(:count).with(:conditions => ['state = ?', 'created']).returns(2)
    lambda {@publisher.publish}.should raise_error("There are 2 sessions not reviewed")
  end
  
  it "should raise error if reviewed sessions don't have decisions" do
    Session.expects(:count).with(
      :joins => "left outer join (
                  SELECT session_id, count(*) AS cnt
                  FROM review_decisions
                  GROUP BY session_id
                ) AS review_decision_count
                ON review_decision_count.session_id = sessions.id",
      :conditions => ['state = ? AND review_decision_count.cnt = 0', 'in_review']).
      returns(2)
    lambda {@publisher.publish}.should raise_error("There are 2 sessions without decision")
  end
  
  it "should send reject e-mails first"
  it "should send acceptance e-mails"
end