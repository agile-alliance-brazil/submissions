# frozen_string_literal: true

shared_examples 'virtual username attribute' do |attribute|
  it 'sets by username' do
    user = FactoryBot.create(:user)
    subject.send(:"#{attribute}_username=", user.username)
    expect(subject.send(attribute)).to eq(user)
  end

  it 'does not set if username is nil' do
    subject.send(:"#{attribute}_username=", nil)
    expect(subject.send(attribute)).to be_nil
  end

  it 'does not set if username is empty' do
    subject.send(:"#{attribute}_username=", '')
    expect(subject.send(attribute)).to be_nil
  end

  it 'does not set if username is only spaces' do
    subject.send(:"#{attribute}_username=", '  ')
    expect(subject.send(attribute)).to be_nil
  end

  it 'provides username from association' do
    user = FactoryBot.create(:user)
    subject.send(:"#{attribute}_username=", user.username)
    expect(subject.send(:"#{attribute}_username")).to eq(user.username)
  end
end
