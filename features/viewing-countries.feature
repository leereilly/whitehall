Feature: Viewing countries

Scenario: View list of all countries
  Given a country "British Antarctic Territory" exists
  And a country "Papua New Guinea" exists
  When I view the list of countries
  Then I should see the country "British Antarctic Territory"
  And I should see the country "Papua New Guinea"

Scenario: View news articles relating to a country
  Given a country "British Antarctic Territory" exists
  And a published news article "Larsen ice sheet disintegrates" exists relating to the country "British Antarctic Territory"
  When I view the country "British Antarctic Territory"
  Then I should see the news article "Larsen ice sheet disintegrates"

Scenario: View policies relating to a country
  Given a country "British Antarctic Territory" exists
  And a published policy "Icebergs of the World, Unite!" exists relating to the country "British Antarctic Territory"
  When I view the country "British Antarctic Territory"
  Then I should see the policy "Icebergs of the World, Unite!"

Scenario: The publication is about a country
  Given a country "British Antarctic Territory" exists
  And a published publication "Penguins have rights too" exists that is about "British Antarctic Territory"
  When I view the country "British Antarctic Territory"
  Then I should see the publication "Penguins have rights too"

Scenario: View priorities for a country
  Given a country "British Antarctic Territory" exists
  And a published international priority "Oil field exploitation" exists relating to the country "British Antarctic Territory"
  When I view the country "British Antarctic Territory"
  Then I should see the international priority "Oil field exploitation"

Scenario: Navigating between pages for a country
Given a country "British Antarctic Territory" exists
  When I view the country "British Antarctic Territory"
  Then I should see the country navigation
  When I navigate to the "British Antarctic Territory" country's about page
  Then I should see the "British Antarctic Territory" country's about page
  And I should see the country navigation
  When I navigate to the "British Antarctic Territory" country's home page
  Then I should see the "British Antarctic Territory" country's home page
