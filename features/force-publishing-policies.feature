Feature: Force Publishing Policies

Background:
  Given I am an editor

Scenario: Publishing a submitted publication
  Given I draft a new policy "Ban Beards"
  When I force publish the policy "Ban Beards"
  Then I should see the policy "Ban Beards" in the list of published documents
  And the policy "Ban Beards" should be visible to the public