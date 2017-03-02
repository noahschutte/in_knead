class AnonController < ApplicationController

  def show
    @anon_id = request[:id]
    @anon_requests = Request.anon_history(@anon_id)
    @anon_thank_yous = ThankYou.anon_history(@anon_id)

    render :json => {
      anonRequests: @anon_requests,
      anonThankYous: @anon_thank_yous
    }
  end

end
