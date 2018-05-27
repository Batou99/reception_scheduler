require 'test_helper'

class ShiftTest < ActiveSupport::TestCase
  setup do
    @user = User.create(username: "user",  email: "user@foo.com",  admin: false, password: "testpass")
    # This is a monday
    @base = Time.parse("2018/1/1T00:00:00+00:00")
  end

  # VALIDATIONS ##########################################
  test "start must happen before end" do
    shift = Shift.new(user: @user, start: @base, finish: @base - 1.hour)

    assert shift.invalid?
    assert shift.errors.added? :base, "a shift has to finish after it starts"

    shift = Shift.new(user: @user, start: @base - 1.hour, finish: @base)

    assert shift.valid?
  end

  test "shift must be within open hours" do
    # 7AM -> 8AM
    shift = Shift.new(user: @user, start: @base + 7.hour, finish: @base + 8.hour)
    assert shift.valid?

    # 1 AM -> 3 AM
    shift = Shift.new(user: @user, start: @base + 1.hour, finish: @base + 3.hour)
    assert shift.valid?

    # 1 AM -> 3:00:01 AM
    shift = Shift.new(user: @user, start: @base + 1.hour, finish: @base + 3.hour + 1.second)
    assert shift.invalid?
    assert shift.errors.added? :finish, "house is closed at that time"

    # 3:00:01 AM -> 7 AM
    shift = Shift.new(user: @user, start: @base + 3.hour + 1.second, finish: @base + 7.hour)
    assert shift.invalid?

    # 3:00:01 AM -> 6:59:59 AM
    shift = Shift.new(user: @user, start: @base + 3.hour + 1.second, finish: @base + 7.hour - 1.second)
    assert shift.invalid?
    assert shift.errors.added? :start, "house is closed at that time"
    assert shift.errors.added? :finish, "house is closed at that time"
  end

  test "no more than 8 hours per shift" do
    # 8 hour shift
    shift = Shift.new(user: @user, start: @base + 7.hour, finish: @base + 15.hour)
    assert shift.valid?

    # 8:00:01 hour shift
    shift = Shift.new(user: @user, start: @base + 7.hour, finish: @base + 15.hour + 1.second)
    assert shift.invalid?
    assert shift.errors.added? :base, "shift is too long, you cannot work more than 8 hours per shift"
  end

  test "no overlapping shifts" do
    user2 = User.create(username: "user2",  email: "user2@foo.com",  admin: false, password: "testpass")

    Shift.create(user: @user, start: @base + 7.hour, finish: @base + 15.hour)

    # No overlapping shifts with yourself
    shift = Shift.new(user: @user, start: @base + 15.hour - 1.second, finish: @base + 16.hour)
    assert shift.invalid?
    assert shift.errors.added? :base, "there can not be overlapping shifts"

    # No overlapping shifts with another user
    shift = Shift.new(user: user2, start: @base + 15.hour - 1.second, finish: @base + 16.hour)
    assert shift.invalid?
    assert shift.errors.added? :base, "there can not be overlapping shifts"
  end

  test "no more than 40 hours a week" do
    prev_monday = @base.prev_occurring(:monday)
    next_monday = @base.next_occurring(:monday)

    # This shift has 5 hours on prev week and 3 hours on this week
    Shift.create(user_id: @user.id, start: @base - 5.hour, finish: @base + 3.hour)

    # This shifts have 8 hours on this week
    1.upto(4) do |num|
      Shift.create(user_id: @user.id, start: @base + num.day - 7.hour, finish: @base + num.day + 1.hour)
    end

    # This shift has 5 hours on current week and 3 hour into the next
    Shift.create(user_id: @user.id, start: next_monday - 5.hour, finish: next_monday + 3.hour)

    # Prev week: 5 hours
    # This week: 40 hours
    # Next week: 3 hours

    # 1 hour shift: Total 41 hours
    shift = Shift.new(user_id: @user.id, start: @base + 5.day, finish: @base + 5.day + 1.hour)
    assert shift.invalid?
    assert shift.errors.added? :base, "you cannot work more than 40 hours a week"

    # 1 hour shift: Total 6 hours on prev week
    shift = Shift.new(user_id: @user.id, start: prev_monday + 1.day, finish: prev_monday + 1.day + 1.hour)
    assert shift.valid?

    # 1 hour shift: Total 4 hours on next week
    prev_monday = @base.next_occurring(:monday)
    shift = Shift.new(user_id: @user.id, start: next_monday + 1.day, finish: next_monday + 1.day + 1.hour)
    assert shift.valid?
  end
end
