Feature: Viewing organisations

Scenario: Organisation page should show policies
  Given the organisation "Attorney General's Office" contains some policies
  And other organisations also have policies
  When I visit the "Attorney General's Office" organisation
  Then I should only see published policies belonging to the "Attorney General's Office" organisation

Scenario: Organisation page should show consultations
  Given the organisation "Attorney General's Office" is associated with consultations "More tea vicar?" and "Cake or biscuit?"
  When I visit the "Attorney General's Office" organisation
  Then I can see links to the consultations "More tea vicar?" and "Cake or biscuit?"

Scenario: Organisation page should show the top minister
  Given the "Attorney General's Office" organisation is associated with several ministers and civil servants
  When I visit the "Attorney General's Office" organisation
  Then I should see the top minister for the "Attorney General's Office" organisation
  And I should see the top civil servant for the "Attorney General's Office" organisation
  And I should be able to view all ministers for the "Attorney General's Office" organisation on a separate page

Scenario: A department is responsible for multiple agencies
  Given that "BIS" is responsible for "Companies House" and "UKTI"
  When I visit the "BIS" organisation
  Then I should see that "BIS" is responsible for "Companies House"
  And I should see that "BIS" is responsible for "UKTI"

Scenario: An agency if the responsibility of multiple departments
  Given that "The stabilisation unit" is the responsibility of "DFID" and "FCO"
  When I visit the "The stabilisation unit" organisation
  Then I should see that "The stabilisation unit" is the responsibility of "DFID"
  And I should see that "The stabilisation unit" is the responsibility of "FCO"

Scenario: Seeing all speeches for an organisation
  Given "Barry Tweaker" is the "Moustachemaster General" for the "Ministry of Facial Topiary"
  And "Margaret Cummerbund" is the "Chinbeard Invigilator" for the "Ministry of Facial Topiary"
  And a published speech "The Wax of Empire" by "Moustachemaster General" on "2011-11-01" at "10 Downing Street"
  And a published speech "The Chin Unseen" by "Chinbeard Invigilator" on "2011-11-02" at "Whitehall"
  When I visit the "Ministry of Facial Topiary" organisation
  Then I should see the following speeches are associated with the "Facial Topiary Management" organisation:
    | Title             |
    | The Wax of Empire |
    | The Chin Unseen   |

Scenario: Navigating between pages for an organisation
  Given the organisation "Cabinet Office" exists
  When I visit the "Cabinet Office" organisation
  Then I should see the organisation navigation
  When I navigate to the "Cabinet Office" organisation's about page
  Then I should see the "Cabinet Office" organisation's about page
  And I should see the organisation navigation
  When I navigate to the "Cabinet Office" organisation's news page
  Then I should see the "Cabinet Office" organisation's news page
  And I should see the organisation navigation
  When I navigate to the "Cabinet Office" organisation's policies page
  Then I should see the "Cabinet Office" organisation's policies page
  And I should see the organisation navigation
  When I navigate to the "Cabinet Office" organisation's publications page
  Then I should see the "Cabinet Office" organisation's publications page
  And I should see the organisation navigation
  When I navigate to the "Cabinet Office" organisation's home page
  Then I should see the "Cabinet Office" organisation's home page
