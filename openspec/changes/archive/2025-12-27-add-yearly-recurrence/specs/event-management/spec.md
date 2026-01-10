## MODIFIED Requirements
### Requirement: The application SHALL support Recurrence
Events SHALL support recurrence patterns: none, daily, weekly, monthly, yearly, with automatic expansion for display and interaction.

#### Scenario: Creating recurring event
Given an event with recurrence "weekly"
When saved
Then individual instances are expanded for calendar display up to 1 year ahead

#### Scenario: Creating yearly event
Given an event with recurrence "yearly"
When saved
Then individual instances are expanded for calendar display up to 1 year ahead

#### Scenario: Displaying recurring events
Given a recurring event on calendar view
When event day is selected
Then all expanded instances for that day are shown in the event list

## ADDED Requirements
### Requirement: The application SHALL handle February 29th in Yearly Recurrence
Yearly recurring events on February 29th SHALL fall back to February 28th on non-leap years to ensure annual occurrence.

#### Scenario: Feb 29th event on leap year
Given an event on February 29th, 2020 (leap year) with yearly recurrence
When expanding instances through 2024 (leap year)
Then instances include:
- Base event on 2020-02-29
- Instance on 2021-02-28 (fallback, non-leap year)
- Instance on 2022-02-28 (fallback, non-leap year)
- Instance on 2023-02-28 (fallback, non-leap year)
- Instance on 2024-02-29 (leap year, original date)

#### Scenario: Regular date with yearly recurrence
Given an event on December 25th with yearly recurrence
When expanding instances for 5 years
Then instances are generated for December 25th of each subsequent year
