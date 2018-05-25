require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user1  = User.create(username: "user1",  email: "user@foo.com",  admin: false, password: "testpass")
    @admin1 = User.create(username: "admin1", email: "admin@foo.com", admin: true,  password: "testpass")
  end

  test "user can modify itself" do
    assert @user1.can_modify_user? @user1.id
  end

  test "non admin user cannot modify other users" do
    user2 = User.create(username: "user2", email: "user@foo.com", admin: false, password: "testpass")

    refute @user1.can_modify_user? @admin1.id
    refute @user1.can_modify_user? user2.id
  end

  test "admin can modify any other user" do
    admin2 = User.create(username: "admin2", email: "admin@foo.com", admin: true, password: "testpass")

    assert @admin1.can_modify_user? @admin1.id
    assert @admin1.can_modify_user? admin2.id
    assert @admin1.can_modify_user? @user1.id
  end
end
