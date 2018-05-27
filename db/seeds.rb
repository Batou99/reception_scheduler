User.create(username: "admin", email: "admin@foo.com", password: "somepass", admin: true)
user = User.create(username: "user",  email: "user@foo.com",  password: "somepass", admin: true)

base        = Time.parse("2018/1/1T00:00:00+00:00")
next_monday = base.next_occurring(:monday)

# This shift has 5 hours on prev week and 3 hours on this week
Shift.create(user_id: user.id, start: base - 7.hour, finish: base + 1.hour)

# This shifts have 8 hours on this week
1.upto(4) do |num|
  Shift.create(user_id: user.id, start: base + num.day - 7.hour, finish: base + num.day + 1.hour)
end

# This shift has 5 hours on current week and 3 hour into the next
Shift.create(user_id: user.id, start: next_monday - 7.hour, finish: next_monday + 1.hour)
