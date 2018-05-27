# README

**Soho House Reception Scheduler**

Soho House runs several private Membership Clubs around the world. To enter the club, you must scan your card at reception.

We'd like you to build a basic scheduling system to help manage the rota for the Shoreditch House reception desk. The system should allow Soho House employees to view and book shifts.

## Installation

This project just uses sqlite as DB so there's no need to install a database server like mysql or postgres.

* Install rails 5.2
* Create and seed DB: `rake db:setup`

## Tests

To run the test suite just do: `rails test`

## Rules
- Shoreditch House is open from 7am until 3am, 7 days a week
- There is only one member of staff on shift at a time
- Shifts can be a maximum of 8 hours long
- An employee can work a maximum of 40 hours per week

## Description

This project creates an API to serve the requested functionality.
To secure the connection uses JWT tokens.

The implementation is quite straighforward but there are a couple of edge cases worthy of note.

### No more than 40 hours a week

The difficulty here stems from shifts being able to span more than one day (e.g start sunday at 23.00 PM and end at monday 3.00 AM)
We need to ensure only the time spend inside the week boundaries counts towards the 40 hours max.
See image:

### No more than one employee per shift

We need to ensure there is no overlap in the shifts

See image:
