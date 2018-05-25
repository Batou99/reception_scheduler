require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest

  def authenticated_header(user)
    token = Knock::AuthToken.new(payload: { sub: user.id }).token
    { 'Authorization': "Bearer #{token}" }
  end

  setup do
    @user          = User.create(username: "user1",  email: "user@foo.com",  admin: false, password: "testpass")
    @admin         = User.create(username: "admin1", email: "admin@foo.com", admin: true,  password: "testpass")
    @create_params = {
      user: {
        username:              "johndoe",
        email:                 "johndoe@foo.com",
        admin:                 true,
        password:              "somepass",
        password_confirmation: "somepass"
      }
    }
    @update_params = {
      user: {
        username:              "jackdoe",
        email:                 "jackdoe@foo.com",
        admin:                 true,
        password:              "otherpass",
        password_confirmation: "otherpass"
      }
    }
  end

  # CONTEXT: non authenticated user ##############################
  test "index: unauthenticated" do
    get "/users", as: :json

    assert_equal 401, response.status
  end

  test "current: unauthenticated" do
    get "/users/current", as: :json

    assert_equal 401, response.status
  end

  test "create: unauthenticated" do
    post "/users", as: :json, params: @create_params

    assert_equal 401, response.status
  end

  test "destroy: unauthenticated" do
    delete "/users/#{@user.id}"

    assert_equal 401, response.status
  end

  # CONTEXT: authenticated user ##############################
  test "index: authenticated" do
    get "/users", as: :json, headers: authenticated_header(@user)

    res = JSON.parse response.body, symbolize_names: true

    assert_equal({status: 200, msg: "Logged in"}, res)
  end

  test "current: authenticated" do
    get "/users/current", as: :json, headers: authenticated_header(@user)

    res             = JSON.parse response.body, symbolize_names: true
    serialized_user = JSON.parse UserSerializer.new(@user.reload).to_json, symbolize_names: true

    assert_equal(serialized_user, res)
  end

  # CONTEXT: create ############################################
  test "create: admin user" do
    post "/users", as: :json, params: @create_params, headers: authenticated_header(@admin)

    user_params = @create_params[:user]
    new_user    = User.last

    assert_equal 200,                    response.status
    assert_equal user_params[:username], new_user.username
    assert_equal user_params[:email],    new_user.email
    assert_equal user_params[:admin],    new_user.admin
  end

  test "create: normal user" do
    post "/users", as: :json, params: @create_params

    assert_equal 401, response.status
  end
  
  # CONTEXT: update ############################################
  test "update: admin" do
    patch "/users/#{@user.id}", as: :json, params: @update_params, headers: authenticated_header(@admin)

    assert_equal 200, response.status
    @user.reload
    user_params = @update_params[:user]

    # Admin status cannot be changed after creation
    refute       @user.admin
    assert_equal user_params[:username], @user.username
    assert_equal user_params[:email],    @user.email
    # FIXME: Verify password change
  end

  test "update: self" do
    patch "/users/#{@user.id}", as: :json, params: @update_params, headers: authenticated_header(@user)

    assert_equal 200, response.status
    @user.reload
    user_params = @update_params[:user]

    # Admin status cannot be changed after creation
    refute       @user.admin
    assert_equal user_params[:username], @user.username
    assert_equal user_params[:email],    @user.email
    # FIXME: Verify password change
  end

  test "update: non admin" do
    patch "/users/#{@admin.id}", as: :json, params: @update_params, headers: authenticated_header(@user)

    assert_equal 401, response.status
  end
end
