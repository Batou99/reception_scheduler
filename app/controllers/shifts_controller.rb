class ShiftsController < ApplicationController
  before_action :authenticate_user
  before_action :authorize, only: [:update, :destroy]

  def index
    render json: Shift.order("start ASC"), each_serializer: ShiftSerializer, root: false
  end

  def show
    shift = Shift.find(params[:id])

    render json: shift, root: false
  end

  def create
    shift      = Shift.new(shift_params)
    shift.user = current_user

    if shift.save
      render json: { msg: "shift created" }, status: 201
    else
      render json: { errors: shift.errors.full_messages }, status: 422
    end
  end

  def update
    shift      = Shift.find(params[:id])
    shift.update_attributes(shift_params)

    if shift.save
      render json: shift, status: 200
    else
      render json: { errors: shift.errors.full_messages }, status: 422
    end
  end

  def destroy
    shift = Shift.find(params[:id])
    shift.destroy

    render json: { msg: "shift deleted sucessfully" }, status: 200
  end

  private

  def shift_params
    params.require(:shift).permit(:start, :finish)
  end

  def authorize
    shift = Shift.find(params[:id])

    return_unauthorized unless current_user.admin? || shift.user == current_user
  end
end
