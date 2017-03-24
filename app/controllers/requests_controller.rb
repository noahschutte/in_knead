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
    @user = User.find(params[:userID])
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
      @request = Request.new(creator: @user, pizzas: params[:pizzas], vendor: params[:vendor])
      if @request.save
        Request.update_video_key(@request, params[:videoKey])
        @signed_request = set_presigned_put_url(@request.video)
        render :json => { signedRequest: @signed_request, videoKey: @request.video }
      else
        render :status => 400, :json => { errorMessage: "Request could not be created." }
      end
    end
  end

  def update
    @request = Request.find(request[:id])
    if params[:blockUser]
      User.block(params[:userID], params[:blockUser])
      render :status => :ok
    elsif params[:transcodeVideo]
      Request.transcode(@request)
      render :status => :ok
    elsif params[:reportVideo]
      Request.report(@request)
      User.report_request(params[:userID], @request.id)
      Request.remove(@request)
      render :status => :ok
    else
      @user = User.find(params[:userID])
      if params[:receivedDonation] && @request.update(status: "received")
        render :status => :ok
      elsif User.reported_request(@user, @request)
        render :status => 400, :json => { errorMessage: "You can't donate to a video that you've reported." }
      elsif User.blocked_user(@user, @request)
        render :status => 400, :json => { errorMessage: "You can't donate to a user that you've blocked." }
      elsif @request.donor_id != nil
        render :status => 400, :json => { errorMessage: "This request has already received a donation." }
      elsif Request.donor_fraud(@user.id)
        render :status => 400, :json => { errorMessage: "Your last donations have not been received yet." }
      elsif @request.update(donor_id: @user.id)
        @request_show = Request.show(@request)
        render :json => { request: @request_show }
      else
        render :status => 400, :json => { errorMessage: "Cannot donate at this time." }
      end
    end
  end

  def destroy
    @request = Request.find(request[:id])
    if @request.status == "active" && @request.donor_id == nil
      @request.destroy
      render :status => :ok
    else
      render :status => 400, :json => { errorMessage: "Request could not be deleted." }
    end
  end

  private
    def set_presigned_put_url(video)
      @s3 = Aws::S3::Resource.new
      @object = @s3.bucket(ENV['S3_REQUESTS']).object("#{video}")
      @put_url = @object.presigned_url(:put, acl: 'public-read', expires_in: 60)
      # p "@put_url"
      # p @put_url
      # p "sub"
      # p @put_url.sub('in-knead-requests.s3.amazonaws.com', "d1ow1u7708l5qk.cloudfront.net")
      # @put_url
    end

end
