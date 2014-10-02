describe "Reviewers Page", ->
  describe ".initializeAutocomplete", ->
    it "should make ajax request to specified path on first call", ->
      setFixtures("<input type='text' id='autocomplete' />")
      $.submissions.reviewers.initializeAutocomplete('#autocomplete')

      # TODO: Mock ajax and verify calls
  describe ".initializeRemoveLinksFeedback", ->
    it "should make ajax request to specified path on first call", ->
      setFixtures("<table><tr><td><a class='remove'/></td></tr><tr><td><a a class='remove'/></td></tr></table>")
      $.submissions.reviewers.initializeRemoveLinksFeedback('.remove')

      # TODO: Mock ajax and verify calls

  describe ".initializeAddFormFeedback", ->
    it "should make ajax request to specified path on first call", ->
      setFixtures("<table id='appendable'>
        <tr id='mock' class='reviewer hidden'>
          <td class='reviewer'></td>
          <td class='state'></td>
          <td class='actions'>
            <a class='remove'/>
          </td>
        </tr>
      </table>
      <form id='form'>
        <input type='submit'/>
      </form>")
      $.submissions.reviewers.initializeAddFormFeedback('#form', '#mock', '#appendable')

      # TODO: Mock ajax and verify calls
