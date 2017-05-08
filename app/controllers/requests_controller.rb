class RequestsController < ApplicationController

  def index
    @total_donated_pizzas = Request.total_donated_pizzas
    @requests = Request.activity
    @thank_yous = ThankYou.activity
    render :json => {
      totalDonatedPizzas: @total_donated_pizzas,
      requests: @requests,
      thankYous: @thank_yous
    }
  end

  def create
    @user = User.find(request_params[:userID])
    Request.failed_upload(@user.id)
    if User.banned(@user.id)
      render :status => 400, :json => { errorMessage: "You have been banned for inappropriate content." }
    elsif User.thank_you_reminders(@user.id).any?
      render :status => 400, :json => { errorMessage: "Please submit a thank you video for your previously successful requests." }
    elsif User.recent_successful_request(@user.id)
      render :status => 400, :json => { errorMessage: "You must wait 14 days after receiving a donation." }
    elsif Request.recent_upload(@user.id)
      render :status => 400, :json => { errorMessage: "Please wait at least 3 minutes to see if your last upload was successful." }
    elsif User.recent_request(@user.id)
      render :status => 400, :json => { errorMessage: "You can only make a request once every 24 hours." }
    else
      Request.expire(@user.id)
      @request = Request.new(creator: @user, pizzas: request_params[:pizzas], vendor: request_params[:vendor])
      if @request.save
        Request.update_video_key(@request, request_params[:videoKey])
        @signed_request = set_presigned_put_url(@request.video)
        render :json => { signedRequest: @signed_request, videoKey: @request.video }
      else
        render :status => 400, :json => { errorMessage: "Request could not be created." }
      end
    end
  end

  def update
    p "params id"
    p params[:id]
    p "params"
    p params
    p "request_update_params"
    p request_update_params
    @request = Request.find(request_update_params[:id])
    if request_update_params[:transcodeVideo]
      Request.transcode(@request)
    elsif request_update_params[:reportVideo]
      User.report_request(request_update_params[:userID], @request.id)
      Request.report(@request)
      Request.remove(@request)
    elsif request_update_params[:blockUser]
      User.block(request_update_params[:userID], request_update_params[:blockUser])
      Request.report(@request)
      Request.remove(@request)
    elsif request_update_params[:receivedDonation]
      Request.received_donation(@request)
    elsif request_update_params[:removalViewed]
      Request.removal_viewed(@request)
    else
      @user = User.find(request_update_params[:userID])
      if User.reported_request(@user, @request)
        render :status => 400, :json => { errorMessage: "You can't donate to a video that you've reported." }
      elsif User.blocked_user(@user, @request)
        render :status => 400, :json => { errorMessage: "You can't donate to a user that you've blocked." }
      elsif @request.donor_id != nil
        render :status => 400, :json => { errorMessage: "This request has already received a donation." }
      elsif Request.donor_fraud(@user.id)
        render :status => 400, :json => { errorMessage: "Your last donations have not been received yet." }
      elsif @request.status == "deleted"
        render :status => 400, :json => { errorMessage: "This request no longer exists." }
      else
        Request.donate(@request, @user.id)
        @request_show = Request.show(@request)
        render :json => { request: @request_show }
      end
    end
    render :status => :ok
  end

  def destroy
    @request = Request.find(request[:id])
    if @request.status == "active" && @request.donor_id == nil
      Request.delete(@request)
      render :status => :ok, :json => { errorMessage: "Request was successfully deleted." }
    else
      render :status => 400, :json => { errorMessage: "Request could not be deleted." }
    end
  end

  private
    def set_presigned_put_url(video)
      @s3 = Aws::S3::Resource.new
      @object = @s3.bucket(ENV['S3_REQUESTS']).object("#{video}")
      @put_url = @object.presigned_url(:put, acl: 'public-read', expires_in: 60)
    end

    def request_params
      params.permit(:userID, :pizzas, :vendor, :videoKey, {:request => [:pizzas, :vendor]})
    end

    def request_update_params
      params.permit(:id, :transcodeVideo, :reportVideo, :userID, :blockUser, :receivedDonation, :removalViewed, user: {}, request: {})
    end

end
