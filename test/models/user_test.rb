require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user  = User.create(username: "user",  email: "user@foo.com",  admin: false, password: "testpass")
    @admin = User.create(username: "admin", email: "admin@foo.com", admin: true,  password: "testpass")

    # This is a monday
    @base        = Time.parse("2018/1/1T00:00:00+00:00")
    @next_monday = @base.next_occurring(:monday)

    # This shift has 5 hours on prev week and 3 hours on this week
    Shift.create(user_id: @user.id, start: @base - 5.hour, finish: @base + 3.hour)

    # This shifts have 8 hours on this week
    1.upto(4) do |num|
      Shift.create(user_id: @user.id, start: @base + num.day - 7.hour, finish: @base + num.day + 1.hour)
    end

    # This shift has 5 hours on current week and 3 hour into the next
    Shift.create(user_id: @user.id, start: @next_monday - 5.hour, finish: @next_monday + 3.hour)
  end

  test "user can modify itself" do
    assert @user.can_modify_user? @user.id
  end

  test "non admin user cannot modify other users" do
    user2 = User.create(username: "user2", email: "user@foo.com", admin: false, password: "testpass")

    refute @user.can_modify_user? @admin.id
    refute @user.can_modify_user? user2.id
  end

  test "admin can modify any other user" do
    admin2 = User.create(username: "admin2", email: "admin@foo.com", admin: true, password: "testpass")

    assert @admin.can_modify_user? @admin.id
    assert @admin.can_modify_user? admin2.id
    assert @admin.can_modify_user? @user.id
  end

  test "user can modify his shifts" do
    shift = Shift.last
    assert @user.can_modify_shift?(shift.id)
  end

  test "user cannot modify other user shifts" do
    other = User.create(username: "other",  email: "other@foo.com",  admin: false, password: "testpass")
    shift = Shift.last

    refute other.can_modify_shift?(shift.id)
  end

  test "admin can modify any shift" do
    shift = Shift.last

    assert @admin.can_modify_shift?(shift.id)
  end

  test "#number_of_hours" do
    # 7 hours of first shift on prev week
    assert_equal 5,  @user.number_of_hours(@base.prev_occurring(:sunday))
    # 3 shifts x 8h + 1 hour of first shift
    assert_equal 40, @user.number_of_hours(@base)

    # 2 hours into the next week
    assert_equal 3, @user.number_of_hours(@next_monday)

    # It can exclude a shift
    assert_equal 0, @user.number_of_hours(@next_monday, Shift.last)
  end
end
