class ThankYouController < ApplicationController

  def create
    @user = User.find(thank_you_params[:userID])
    @thank_you = ThankYou.new(creator: @user, donor_id: thank_you_params[:donor_id], request_id: thank_you_params[:requestId], pizzas: thank_you_params[:pizzas], vendor: thank_you_params[:vendor])
    if @thank_you.save
      ThankYou.update_video_key(@thank_you, thank_you_params[:videoKey])
      # Change ThankYou.viewed to true on creation if the donor has blocked the ThankYou creator
      ThankYou.donor_blocked(@thank_you)
      @signed_request = set_presigned_put_url(@thank_you.video)
      render :json => { signedRequest: @signed_request, videoKey: @thank_you.video }
    else
      render :status => 400, :json => { errorMessage: "Thank You could not be created." }
    end
  end

  def update
    @thank_you = ThankYou.find(thank_you_update_params[:id])
    if thank_you_update_params[:transcodeVideo]
      ThankYou.transcode(@thank_you)
    elsif thank_you_update_params[:viewedVideo]
      ThankYou.view(@thank_you)
    elsif thank_you_update_params[:removalViewed]
      ThankYou.removal_viewed(@thank_you)
    elsif thank_you_update_params[:reportVideo]
      User.report_thank_you(thank_you_update_params[:userID], @thank_you.id)
      ThankYou.report(@thank_you)
      ThankYou.remove(@thank_you)
    elsif thank_you_update_params[:blockUser]
      User.block(thank_you_update_params[:userID], thank_you_update_params[:blockUser])
      ThankYou.report(@thank_you)
      ThankYou.remove(@thank_you)
    end
    render :status => :ok
  end

  def destroy
    @thank_you = ThankYou.find(request[:id])
    ThankYou.delete(@thank_you)
    render :status => :ok
  end

  private
    def set_presigned_put_url(video)
      @s3 = Aws::S3::Resource.new
      @object = @s3.bucket(ENV['S3_THANKYOUS']).object("#{video}")
      @put_url = @object.presigned_url(:put, acl: 'public-read', expires_in: 60)
    end

    def thank_you_params
      params.permit(:userID, :donor_id, :requestId, :pizzas, :vendor, :videoKey, {:thank_you => [:pizzas, :vendor, :donor_id]})
    end

    def thank_you_update_params
      params.permit(:id, :transcodeVideo, :viewedVideo, :removalViewed, :reportVideo, :blockUser, :userID)
    end

end
