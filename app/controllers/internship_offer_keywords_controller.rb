class InternshipOfferKeywordsController < ApplicationController
  protect_from_forgery with: :null_session
  def search
    render json: InternshipOfferKeyword.search(params.require(:keyword)),
           status: 200
  end
end
