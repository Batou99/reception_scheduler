class ShiftsController < ApplicationController
  before_action :authenticate_user
  before_action :authorize, only: [:update, :destroy]

  def index
    render json: Shift.order("start ASC"), each_serializer: ShiftSerializer
  end

  def show
    shift = Shift.find(params[:id])

    render_ok shift
  end

  def create
    shift      = Shift.new(shift_params)
    shift.user = current_user

    if shift.save
      render_ok({ msg: "shift created" }, 201)
    else
      render_error shift.errors.full_messages
    end
  end

  def update
    shift      = Shift.find(params[:id])
    shift.update_attributes(shift_params)

    if shift.save
      render_ok shift
    else
      render_error shift.errors.full_messages
    end
  end

  def destroy
    shift = Shift.find(params[:id])
    shift.destroy

    render_ok msg: "shift deleted sucessfully"
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
