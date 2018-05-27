class ApplicationController < ActionController::API
  include Knock::Authenticable

  def return_unauthorized
    render status: :unauthorized
  end

  def return_ok(data, status_code = 200)
    render json: data, status: status_code
  end

  def return_error(data, status_code = 422)
    render json: { errors: data }, status: status_code
  end

  protected

  def authorize_as_admin
    return_unauthorized unless current_user.present? && current_user.admin
  end
end
