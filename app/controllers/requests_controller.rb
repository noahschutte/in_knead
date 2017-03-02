class RequestsController < ApplicationController
  # before_action :set_s3_direct_post, only: [:index, :show, :create, :update]

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

  # Can I remove the show route?
  def show
    @request = Request.find(request[:id])
    render :json => { request: @request }
  end

  def create
    @user = User.find(request[:userID])
    if User.recent_successful_request(@user.id)
      render :json => { errorMessage: "You must wait 14 days after receiving a donation." }
    elsif User.recent_request(@user.id)
      render :json => { errorMessage: "You can only make a request once every 24 hours." }
    end
    Request.expire(@user.id)
    @request = Request.new(creator: @user, pizzas: params[:pizzas], vendor: params[:vendor], video: params[:videoKey] )
    if @request.save
      @signed_request = set_presigned_put_url(@request.video)
      render :json => {
        signedRequest: @signed_request
      }
    else
      render :json => { errorMessage: "Request could not be created." }
    end
  end

  def update
    if params[:transcodedVideo]
      @transcoded_request = Request.find_by(video: params[:transcodedVideo])
      @transcoded_request.update(transcoded: true)
      render :json => { errorMessage: "Request updated as transcoded." }
    elsif params[:reportVideo]
      @report_request = Request.find_by(video: params[:reportVideo])
      @report_request.increment(:reports)
      @report_request.save
      render :json => { errorMessage: "Request has been reported." }
    else
      @request = Request.find(params[:id])
      @user = User.find(params[:userID])
      if params[:receivedDonation] && @request.update(status: "received")
        render :json => { errorMessage: "Request marked as received." }
      elsif User.recent_donation(@user.id)
        render :json => { errorMessage: "You have recently made a donation." }
      elsif @request.donor_id != nil
        render :json => { errorMessage: "This request has already received a donation." }
      elsif Request.donor_fraud(@user.id)
        render :json => { errorMessage: "Your last donations have not been received yet." }
      elsif @request.update(donor_id: @user.id)
        # Can I just render success message instead of returning anything else?
        @anon = User.find(@request.creator_id)
        @anon_email = @anon.current_email
        # Remove @request_show?
        @request_show = Request.show(@request.id)

        # Remove request?
        render :json => {
          request: @request_show,
          anonEmail: @anon_email
        }
      else
        render :json => { errorMessage: "Cannot donate at this time." }
      end
    end
  end

  def destroy
    @request = Request.find(request[:id])
    if @request.status == "active" && @request.donor_id == nil
      @request.destroy
      render :json => { errorMessage: "Request was deleted." }
    else
      render :json => { errorMessage: "Request could not be deleted." }
    end
  end

  private
    def set_presigned_put_url(object_name)
      @s3 = Aws::S3::Resource.new
      @object = @s3.bucket(ENV['S3_REQUESTS']).object("#{object_name}")
      @put_url = @object.presigned_url(:put, acl: 'public-read', expires_in: 60)
      # p "@put_url"
      # p @put_url
      # p "sub"
      # p @put_url.sub('in-knead-requests.s3.amazonaws.com', "d1ow1u7708l5qk.cloudfront.net")
      # @put_url
    end
end
