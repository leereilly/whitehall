Feature: Fact checking policies
  In order to ensure we're not publishing any inaccuracies in our policies
  As someone involved in drafting policy
  I want to garner comments on a draft policy from other individuals

Scenario: Policy writer requests fact checking
  Given I am logged in as a policy writer
  And I have drafted a policy
  When I request that "fact-checker@example.com" fact checks the policy
  Then "fact-checker@example.com" should receive an email requesting fact checking

Scenario: Departmental editor requests fact checking
  Given I am logged in as a departmental editor
  And I have drafted a policy
  When I request that "fact-checker@example.com" fact checks the policy
  Then "fact-checker@example.com" should receive an email requesting fact checking

Scenario: Fact checker views the draft policy
  Given "fact-checker@example.com" has received an email requesting they fact check a draft policy titled "Check me"
  When "fact-checker@example.com" clicks the email link to the draft policy
  Then they should see the draft policy titled "Check me"

Scenario: Fact checker enters feedback
  Given "fact-checker@example.com" has received an email requesting they fact check a draft policy titled "Check me"
  When "fact-checker@example.com" clicks the email link to the draft policy
  And they provide feedback "We cannot establish the moral character of all dogs"
  Then they should be notified "Your feedback has been saved"

Scenario: Policy writer reviews fact checker comments
  Given a fact checker has commented "This looks good" on the draft policy titled "Check me"
  When I am logged in as a policy writer
  And I visit the list of draft policies
  And I click edit for the policy "Check me"
  Then I should see the fact checking feedback "This looks good"

Scenario: Departmental editor reviews fact checker comments
  Given a fact checker has commented "This looks good" on the draft policy titled "Check me"
  When I am logged in as a departmental editor
  And I visit the list of draft policies
  And I click edit for the policy "Check me"
  Then I should see the fact checking feedback "This looks good"