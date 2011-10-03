Feature: Viewing published policies
In order to obtain useful information about government
A member of the public
Should be able to view policies

Scenario: Publishing a policy that has a PDF attachment
  Given a published policy titled "Policy" with a PDF attachment
  When I visit the policy titled "Policy"
  Then I should see a link to the PDF attachment