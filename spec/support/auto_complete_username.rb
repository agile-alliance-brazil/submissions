# frozen_string_literal: true

shared_examples 'virtual username attribute' do |attribute|
  it 'should set by username' do
    user = FactoryBot.create(:user)
    subject.send(:"#{attribute}_username=", user.username)
    expect(subject.send(attribute)).to eq(user)
  end

  it 'should not set if username is nil' do
    subject.send(:"#{attribute}_username=", nil)
    expect(subject.send(attribute)).to be_nil
  end

  it 'should not set if username is empty' do
    subject.send(:"#{attribute}_username=", '')
    expect(subject.send(attribute)).to be_nil
  end

  it 'should not set if username is only spaces' do
    subject.send(:"#{attribute}_username=", '  ')
    expect(subject.send(attribute)).to be_nil
  end

  it 'should provide username from association' do
    user = FactoryBot.create(:user)
    subject.send(:"#{attribute}_username=", user.username)
    expect(subject.send(:"#{attribute}_username")).to eq(user.username)
  end
end
