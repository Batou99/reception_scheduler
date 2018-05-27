# README

**Soho House Reception Scheduler**

Soho House runs several private Membership Clubs around the world. To enter the club, you must scan your card at reception.

We'd like you to build a basic scheduling system to help manage the rota for the Shoreditch House reception desk. The system should allow Soho House employees to view and book shifts.

## Installation

This project just uses sqlite as DB so there's no need to install a database server like mysql or postgres.

* Install rails 5.2
* Create and seed DB: `rake db:setup`

### Seed data

There are 2 users 
1. admin
  - username: admin
  - email: admin@foo.com
  - password: somepass
2. user
  - username: user
  - email: user@foo.com
  - password: somepass

And there are 6 shifts created for user `user` that total
1. 7 hours on the week before `1/1/2018`
2. 40 hours on the week of `1/1/2018`
3. 1 hour on the week of `7/1/2018`

## Tests

To run the test suite just do: `rails test`

## Run application

Just `rails s`

## Rules
- Shoreditch House is open from 7am until 3am, 7 days a week
- There is only one member of staff on shift at a time
- Shifts can be a maximum of 8 hours long
- An employee can work a maximum of 40 hours per week

## Extra rules
This has been added because I thought they would offer a better experience

### User roles
A user can be a normal `user` or an `admin`. 

#### A user 

1. Can only update/delete its own shifts.
2. Cannot create new users
3. Cannot modify his `admin` status
4. Can modify his username and email

#### An admin

1. Can update/delete any other users shifts
2. Can create new users (including admins)
3. Can update other users (but not admin status)

## Notes

This project creates an API to serve the requested functionality.
To secure the connection uses JWT tokens.
![max hours](https://user-images.githubusercontent.com/419903/40587226-9d180d3e-61cc-11e8-82b5-e6bf3cd02824.png)

The implementation is quite straighforward but there are a couple of edge cases worthy of note.

### No more than 40 hours a week

The difficulty here stems from shifts being able to span more than one day (e.g start sunday at 23.00 PM and end at monday 3.00 AM)
We need to ensure only the time spend inside the week boundaries counts towards the 40 hours max.
See image:

![max hours](https://user-images.githubusercontent.com/419903/40587137-8458391e-61cb-11e8-809e-31d89a919049.png)

### No more than one employee per shift

We need to ensure there is no overlap in the shifts

See image:

![overlap](https://user-images.githubusercontent.com/419903/40587163-c35cb504-61cb-11e8-95cd-2e973c431340.png)

## Test drive

You can use [postman](https://www.getpostman.com/) to test the application

1. `POST /api/v1/users/token` with the user credentials to get a `JWT` token

![get_token](https://user-images.githubusercontent.com/419903/40587437-33e54824-61cf-11e8-8c3a-62eabff5fb99.png)

2. `GET /api/v1/shifts` with an `Authentication` header to list the shifts

![list_shifts](https://user-images.githubusercontent.com/419903/40587439-364f41d2-61cf-11e8-88cb-defc7380388f.png)
