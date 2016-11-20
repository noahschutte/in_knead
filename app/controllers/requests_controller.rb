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
    @request = Request.new(creator: @user, pizzas: params[:pizzas], vendor: params[:vendor], video: params[:videoKey] )
    if User.recent_successful_request(@user.id)
      render :json => { errorMessage: "You must wait 14 days after receiving a donation." }
    elsif User.recent_request(@user.id)
      render :json => { errorMessage: "You can only make a request once every 24 hours." }
    elsif @request.save
      @pizzas = Request.total_pizzas_donated
      @donated_pizzas = @pizzas ? @pizzas : 0
      @requests = Request.open_requests
      @signed_request = set_presigned_put_url(@request.video)
      render :json => { requests: @requests, totalDonatedPizzas: @donated_pizzas, signedRequest: @signed_request }
    else
      render :json => { errorMessage: "Request was not created." }
    end
  end

  def update
    @donor = User.find(params[:userID])
    @request = Request.find(params[:id])
    if Request.active_donation(@donor)
      render :json => { errorMessage: "You have recently made a donation." }
    elsif @request.update(donor_id: @donor.id)
      @requests = Request.open_requests
      @pizzas = Request.total_pizzas_donated
      @active_donation = Request.active_donation(@donor)

      @anon = User.find(@request.creator_id)
      @anon_email = @anon.current_email

      render :json => { totalDonatedPizzas: @pizzas, requests: @requests, activeDonation: @active_donation, anonEmail: @anon_email }
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
    def set_presigned_put_url(object_name)
      @s3 = Aws::S3::Resource.new
      @object = @s3.bucket(ENV['S3_BUCKET']).object("uploads/#{object_name}")
      @put_url = @object.presigned_url(:put, acl: 'public-read', expires_in: 60)
      return @put_url
    end
end
