class RequestsController < ApplicationController
  # before_action :set_s3_direct_post, only: [:index, :show, :create, :update]

  def index
    @pizzas = Request.total_pizzas_donated
    @donated_pizzas = @pizzas ? @pizzas : 0
    @requests = Request.open_requests
    @asset = S3_BUCKET.object('iwantpizza.mp4')
    @url = @asset.presigned_url(:get)
    if @requests.any?
      render :json => { totalDonatedPizzas: @donated_pizzas, requests: @requests, url: @url }
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
    request = Request.new(creator: @user, first_name: @user.first_name, pizzas: params[:pizzas], vendor: params[:vendor], video: params[:videoKey] )
    if User.recent_successful_request(@user.id)
      render :json => { errorMessage: "You must wait 14 days after receiving a donation." }
    elsif User.recent_request(@user.id)
      render :json => { errorMessage: "You can only make a request once every 24 hours." }
    elsif request.save
      @pizzas = Request.total_pizzas_donated
      @donated_pizzas = @pizzas ? @pizzas : 0
      @requests = Request.open_requests

      # Prepare Signed Request
      @signed_request = set_s3_direct_post(request.video)

      render :json => { requests: @requests, totalDonatedPizzas: @donated_pizzas, signedRequest: @signed_request }
    else
      render :json => { errorMessage: "Request was not created." }
    end
  end

  def update
    @donor = User.find(params[:userID])
    @request = Request.find(params[:id])
    if Request.active_donation(@donor).any?
      render :json => { errorMessage: "You have recently made a donation." }
    elsif @request.update(donor_id: @donor.id)
      @requests = Request.open_requests
      @pizzas = Request.total_pizzas_donated
      @active_donation = Request.active_donation(@donor)
      render :json => { totalDonatedPizzas: @pizzas, requests: @requests, activeDonation: @active_donation }
    else
      render :json => { errorMessage: "Cannot donate at this time." }
    end
  end

  def destroy
    @request = Request.find_by(video: params[:videoKey])
    if @request.destroy
      @pizzas = Request.total_pizzas_donated
      @donated_pizzas = @pizzas ? @pizzas : 0
      @requests = Request.open_requests
      render :json => { requests: @requests, totalDonatedPizzas: @donated_pizzas, errorMessage: "Request could not be created." }
    else
      render :json => { errorMessage: "Video could not be uploaded, but request could not be deleted." }
    end
  end

  private
    def set_s3_direct_post(key)
      S3_BUCKET.presigned_post(key: key, success_action_status: '201', acl: 'public-read')
    end

end
