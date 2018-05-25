class ShiftsController < ApplicationController
  before_action :authenticate_user, only: [:auth]

  def index
    render json: { service: "auth-api", status: 200 }
  end

  def auth
    render json: { status: 200, msg: "You are logged in as #{current_user.username}" }
  end
end
