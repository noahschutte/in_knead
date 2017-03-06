class ThankYouController < ApplicationController

  def create
    @user = User.find(params[:userID])
    @thank_you = ThankYou.new(creator: @user, donor_id: params[:donor_id], request_id: params[:requestId], pizzas: params[:pizzas], vendor: params[:vendor], video: params[:videoKey])
    if @thank_you.save
      @signed_request = set_presigned_put_url(@thank_you.video)
      render :json => { signedRequest: @signed_request }
    else
      render :status => 400, :json => { errorMessage: "Thank You could not be created." }
    end
  end

  def update
    if params[:transcodedVideo]
      @transcoded_thank_you = ThankYou.find_by(video: params[:transcodedVideo])
      @transcoded_thank_you.update(transcoded: true)
      render :status => :ok
    elsif params[:reportVideo]
      @report_thank_you = ThankYou.find(request[:id])
      @report_thank_you.increment(:reports)
      @report_thank_you.save
      render :status => :ok
    elsif params[:viewedVideo]
      @donorViewedThankYou = ThankYou.find(request[:id])
      @donorViewedThankYou.update(donor_viewed: true)
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
    def set_presigned_put_url(object_name)
      @s3 = Aws::S3::Resource.new
      @object = @s3.bucket(ENV['S3_THANKYOUS']).object("#{object_name}")
      @put_url = @object.presigned_url(:put, acl: 'public-read', expires_in: 60)
      # p "@put_url"
      # p @put_url
      # p "sub"
      # p @put_url.sub('in-knead-thankyous.s3.amazonaws.com', "d244yzatrec2va.cloudfront.net")
      # @put_url
    end

end
