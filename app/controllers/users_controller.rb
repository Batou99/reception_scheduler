class UsersController < ApplicationController
  before_action :authenticate_user,  only: [:index, :current, :update]
  before_action :authorize_as_admin, only: [:create, :destroy]
  before_action :authorize,          only: [:update]

  def index
    return_ok msg: "Logged in"
  end

  def current
    current_user.update!(last_login: Time.now)
    render json: current_user
  end

  def create
    user = User.new(user_params)

    if user.save
      return_ok({ msg: "User created" }, 201)
    end
  end

  def update
    # Admin status cannot be changed after creation
    filtered_params = user_params.dup
    filtered_params.delete("admin")

    user = User.find(params[:id])

    if user.update(filtered_params)
      return_ok msg: "User details updated"
    end
  end

  def destroy
    user = User.find(params[:id])

    if user.destroy
      return_ok msg: "User deleted"
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :admin)
  end

  def authorize
    return_unauthorized unless current_user && current_user.can_modify_user?(params[:id])
  end
end
