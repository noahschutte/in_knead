class ThankYouController < ApplicationController

  def create
    @user = User.find(request[:userID])
    @recent_successful_request = User.recent_successful_request(@user.id)
    @thank_you = ThankYou.new(creator: @user, request: @recent_successful_request, pizzas: params[:pizzas], vendor: params[:vendor], video: params[:videoKey] )
    @recent_request = User.recent_request(@user.id)

    if @thank_you.save!
      @recent_thank_you = User.recent_thank_you(@user.id)
      @pizzas = Request.total_pizzas_donated
      @donated_pizzas = @pizzas ? @pizzas : 0
      @requests = Request.open_requests
      @thank_yous = ThankYou.activity
      @signed_request = set_presigned_put_url(@thank_you.video)
      render :json => { requests: @requests, thankYous: @thank_yous, totalDonatedPizzas: @donated_pizzas, signedRequest: @signed_request, recentThankYou: @thank_you }
    else
      render :json => { errorMessage: "Thank You was not created." }
    end
  end

  def show
    @thank_you = ThankYou.find(request[:thank_you_id])
    render :json => { thankYou: @thank_you }
  end

  private
    def set_presigned_put_url(object_name)
      @s3 = Aws::S3::Resource.new
      @object = @s3.bucket(ENV['S3_BUCKET']).object("uploads/#{object_name}")
      @put_url = @object.presigned_url(:put, acl: 'public-read', expires_in: 60)
      return @put_url
    end

end
