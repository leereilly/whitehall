Feature: Reviewing policies
In order to allow the public to view policies
A departmental editor
Should be able to publish policies

Scenario: Draft policies shouldn't be viewable by the public
  Given I am logged in as "George"
  And I have written a policy called "Legalise beards"
  Then the policy "Legalise beards" should not be visible to the public

Scenario: Publishing a policy that's been submitted to the second set of eyes
  Given "Ben Beardson" submitted "Legalise beards" with body "Beards for everyone!"
  And I visit the list of policies awaiting review
  When I publish the policy called "Legalise beards"
  Then the policy "Legalise beards" should be visible to the public