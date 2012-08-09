describe "AcceptedSessions", ->
  it "should hide all authors' bio", ->
    setFixtures(sandbox {class: 'bio'})
    expect($('.bio')).toBeVisible()
    new AcceptedSessions().load()
    expect($('.bio')).toBeHidden()