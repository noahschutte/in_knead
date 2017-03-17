class ThankYouController < ApplicationController

  def create
    @user = User.find(params[:userID])
    @thank_you = ThankYou.new(creator: @user, donor_id: params[:donor_id], request_id: params[:requestId], pizzas: params[:pizzas], vendor: params[:vendor])
    if @thank_you.save
      ThankYou.update_video_key(@thank_you, params[:videoKey])
      @signed_request = set_presigned_put_url(@thank_you.video)
      render :json => { signedRequest: @signed_request, videoKey: @thank_you.video }
    else
      render :status => 400, :json => { errorMessage: "Thank You could not be created." }
    end
  end

  def update
    @thank_you = ThankYou.find(request[:id])
    if params[:transcodedVideo]
      ThankYou.transcode(@thank_you)
      render :status => :ok
    elsif params[:reportedVideo]
      ThankYou.report(@thank_you)
      User.report_thank_you(params[:userID], @thank_you.id)
      ThankYou.remove(@thank_you)
      render :status => :ok
    elsif params[:viewedVideo]
      ThankYou.view(@thank_you)
      render :status => :ok
    end
  end

  def destroy
    @thank_you = ThankYou.find(request[:id])
    if @thank_you.destroy
      render :status => :ok
    else
      render :status => 400, :json => { errorMessage: "Thank You entry could not be deleted." }
    end
  end

  private
    def set_presigned_put_url(video)
      @s3 = Aws::S3::Resource.new
      @object = @s3.bucket(ENV['S3_THANKYOUS']).object("#{video}")
      @put_url = @object.presigned_url(:put, acl: 'public-read', expires_in: 60)
      # p "@put_url"
      # p @put_url
      # p "sub"
      # p @put_url.sub('in-knead-thankyous.s3.amazonaws.com', "d244yzatrec2va.cloudfront.net")
      # @put_url
    end

end
