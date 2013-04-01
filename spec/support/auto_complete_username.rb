shared_examples "virtual username attribute" do |attribute|
  it "should set by username" do
    user = FactoryGirl.create(:user)
    subject.send(:"#{attribute}_username=", user.username)
    subject.send(attribute).should == user
  end

  it "should not set if username is nil" do
    subject.send(:"#{attribute}_username=", nil)
    subject.send(attribute).should be_nil
  end

  it "should not set if username is empty" do
    subject.send(:"#{attribute}_username=", "")
    subject.send(attribute).should be_nil
  end

  it "should not set if username is only spaces" do
    subject.send(:"#{attribute}_username=", "  ")
    subject.send(attribute).should be_nil
  end

  it "should provide username from association" do
    user = FactoryGirl.create(:user)
    subject.send(:"#{attribute}_username=", user.username)
    subject.send(:"#{attribute}_username").should == user.username
  end
end