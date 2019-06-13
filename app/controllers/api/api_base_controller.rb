module Api
  class ApiBaseController < ActionController::Base
    skip_before_action :verify_authenticity_token

    private

    def bearer
      request.env['Authorization'] || request.env['HTTP_AUTHORIZATION'] || params[:token]
    end

    def token
      bearer && bearer.split("Bearer ")[1]
    end

    def current_api_user
      query = Users::Operator.where(api_token: token)
      @current_api_user ||= query.first
    end

    def authenticate_api_user!
      return render json: {message: 'unauthorized'}, status: :unauthorized unless current_api_user
    end
  end
end
