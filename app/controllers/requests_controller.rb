class RequestsController < ApplicationController
  # before_action :set_s3_direct_post, only: [:index, :show, :create, :update]

  def index
    @pizzas = Request.total_pizzas_donated
    @donated_pizzas = @pizzas ? @pizzas : 0
    @requests = Request.open_requests
    @thank_yous = ThankYou.activity
    if @requests.any? || @thank_yous.any?
      render :json => { totalDonatedPizzas: @donated_pizzas, requests: @requests, thankYous: @thank_yous }
    else
      render :json => { totalDonatedPizzas: @donated_pizzas,  errorMessage: 'No current requests.', url: @url }
    end
  end

  def show
    @request = Request.find(request[:request_id])
    render :json => { request: @request }
  end

  def create
    @user = User.find(request[:userID])
    @recent_successful_request = User.recent_successful_request(@user.id)
    @recent_request = User.recent_request(@user.id)
    if @recent_successful_request
      render :json => { errorMessage: "You must wait 14 days after receiving a donation." }
    elsif @recent_request
      render :json => { errorMessage: "You can only make a request once every 24 hours." }
    else
      Request.expire(@user.id)
      @request = Request.new(creator: @user, pizzas: params[:pizzas], vendor: params[:vendor], video: params[:videoKey] )
      if @request.save
        @pizzas = Request.total_pizzas_donated
        @donated_pizzas = @pizzas ? @pizzas : 0
        @requests = Request.open_requests
        @thank_yous = ThankYou.activity
        @signed_request = set_presigned_put_url(@request.video)
        render :json => { requests: @requests, thankYous: @thank_yous, totalDonatedPizzas: @donated_pizzas, signedRequest: @signed_request }
      else
        render :json => { errorMessage: "Request could not be created." }
    end
  end

  def update
    if params[:transcodedVideo]
      @transcodedRequest = Request.find_by(video: params[:transcodedVideo])
      @transcodedRequest.update(transcoded: true)
      render :json => { errorMessage: "success" }
    else
      @request = Request.find(params[:id])
      @user = User.find(params[:userID])
      if params[:receivedDonation] && @request.update(status: "received")
        @recent_successful_request = User.recent_successful_request(@user.id)
        render :json => { recentSuccessfulRequest: @recent_successful_request }
      elsif Request.active_donation(@user)
        render :json => { errorMessage: "You have recently made a donation." }
      elsif @request.donor_id != nil
        render :json => { errorMessage: "This request has already received a donation." }
      elsif Request.donor_fraud(@user.id)
        render :json => { errorMessage: "Your last donations have not been received yet." }
      elsif @request.update(donor_id: @user.id)
        @requests = Request.open_requests
        @thank_yous = ThankYou.activity
        @pizzas = Request.total_pizzas_donated
        @active_donation = Request.active_donation(@user)
        @anon = User.find(@request.creator_id)
        @anon_email = @anon.current_email
        @request_show = Request.show(@request.id)

        render :json => { totalDonatedPizzas: @pizzas, request: @request_show, requests: @requests, thankYous: @thank_yous, activeDonation: @active_donation, anonEmail: @anon_email }
      else
        render :json => { errorMessage: "Cannot donate at this time." }
      end
    end
  end

  def destroy
    @request = Request.find_by(video: params[:videoKey])
    if @request.destroy
      @pizzas = Request.total_pizzas_donated
      @donated_pizzas = @pizzas ? @pizzas : 0
      @requests = Request.open_requests
      @thank_yous = ThankYou.activity
      render :json => { requests: @requests, thankYous: @thank_yous, totalDonatedPizzas: @donated_pizzas, errorMessage: "Request could not be created." }
    else
      render :json => { errorMessage: "Video could not be uploaded, but request could not be deleted." }
    end
  end

  private
    def set_presigned_put_url(object_name)
      @s3 = Aws::S3::Resource.new
      @object = @s3.bucket(ENV['S3_REQUESTS']).object("#{object_name}")
      @put_url = @object.presigned_url(:put, acl: 'public-read', expires_in: 60)
      p "@put_url"
      p @put_url
      p "sub"
      p @put_url.sub('in-knead-requests.s3.amazonaws.com', "d1ow1u7708l5qk.cloudfront.net")
      @put_url
    end
end
