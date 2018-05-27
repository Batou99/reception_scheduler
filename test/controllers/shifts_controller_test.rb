require 'test_helper'

class ShiftsControllerTest < ActionDispatch::IntegrationTest
  setup do
    # This is a monday
    @base  = Time.parse("2018/1/1T00:00:00+00:00")
    @user  = User.create(username: "user1",  email: "user@foo.com",  admin: false, password: "testpass")
    @admin = User.create(username: "admin1", email: "admin@foo.com", admin: true,  password: "testpass")
    @shift = Shift.create(user: @user, start: @base, finish: @base + 1.hour)
    @create_params = {
      shift: {
        start:  @base + 1.day,
        finish: @base + 1.day + 8.hours
      }
    }
    @update_params = {
      shift: {
        start:  @base + 30.minutes
      }
    }
  end

  # CONTEXT: non authenticated user ##############################
  test "index: unauthenticated" do
    get "/shifts", as: :json

    assert_equal 401, response.status
  end

  test "show: unauthenticated" do
    get "/shifts/#{@shift.id}", as: :json

    assert_equal 401, response.status
  end

  test "create: unauthenticated" do
    post "/shifts", as: :json, params: @create_params

    assert_equal 401, response.status
  end

  test "update: unauthenticated" do
    patch "/shifts/#{@shift.id}", as: :json, params: @update_params

    assert_equal 401, response.status
  end

  test "destroy: unauthenticated" do
    delete "/shifts/#{@shift.id}", as: :json

    assert_equal 401, response.status
  end


  # CONTEXT: authenticated user #################################
  test "index: authenticated" do
    get "/shifts", as: :json, headers: authenticated_header(@user)

    res              = JSON.parse response.body,                       symbolize_names: true
    serialized_shift = JSON.parse ShiftSerializer.new(@shift).to_json, symbolize_names: true

    assert_equal 200,                response.status
    assert_equal [serialized_shift], res
  end

  test "show: authenticated" do
    get "/shifts/#{@shift.id}", as: :json, headers: authenticated_header(@user)

    res              = JSON.parse response.body,                       symbolize_names: true
    serialized_shift = JSON.parse ShiftSerializer.new(@shift).to_json, symbolize_names: true

    assert_equal 200,                response.status
    assert_equal serialized_shift, res
  end

  test "create: authenticated" do
    post "/shifts", as: :json, params: @create_params, headers: authenticated_header(@user)

    res = JSON.parse response.body, symbolize_names: true

    assert_equal 201,             response.status
    assert_equal "shift created", res[:msg]
    assert_equal Shift.last.user, @user
  end

  test "create: cannot create shift for another user" do
    params = @create_params.merge(user_id: @admin.id)
    post "/shifts", as: :json, params: params, headers: authenticated_header(@user)

    res = JSON.parse response.body, symbolize_names: true

    assert_equal 201,             response.status
    assert_equal "shift created", res[:msg]
    assert_equal Shift.last.user, @user
  end

  test "create: displays create errors" do
    post "/shifts", as: :json, params: { shift: { start: @base } }, headers: authenticated_header(@user)

    res = JSON.parse response.body, symbolize_names: true

    assert_equal 422, response.status
    assert_equal({ errors: ["Finish can't be blank"] }, res)
  end

  test "update: authenticated" do
    patch "/shifts/#{@shift.id}", as: :json, params: @update_params, headers: authenticated_header(@user)

    res = JSON.parse response.body,                                           symbolize_names: true
    serialized_shift = JSON.parse ShiftSerializer.new(@shift.reload).to_json, symbolize_names: true

    assert_equal 200,              response.status
    assert_equal serialized_shift, res
  end

  test "update: displays create errors" do
    invalid_params = { shift: { start: @base + 7.hours} }
    patch "/shifts/#{@shift.id}", as: :json, params: invalid_params, headers: authenticated_header(@user)

    res = JSON.parse response.body, symbolize_names: true

    assert_equal 422, response.status
    assert_equal({ errors: ["a shift has to finish after it starts"] }, res)
  end

  test "destroy: authenticated, own shift" do
    delete "/shifts/#{@shift.id}", as: :json, headers: authenticated_header(@user)

    res = JSON.parse response.body, symbolize_names: true

    assert_equal 200, response.status
    assert_equal({ msg: "shift deleted sucessfully" }, res)
  end

  test "destroy: some other user (by non admin)" do
    other  = User.create(username: "other",  email: "other@foo.com",  admin: false, password: "testpass")

    delete "/shifts/#{@shift.id}", as: :json, headers: authenticated_header(other)

    assert_equal 401, response.status
  end

  test "destroy: authenticated, as admin" do
    delete "/shifts/#{@shift.id}", as: :json, headers: authenticated_header(@admin)

    res = JSON.parse response.body, symbolize_names: true

    assert_equal 200, response.status
    assert_equal({ msg: "shift deleted sucessfully" }, res)
  end

end
