class UsersController < ApplicationController

  def index
    @pizzas = Request.total_pizzas_donated
    render :json => { totalDonatedPizzas: @pizzas }
  end

  def show
    @pizzas = Request.total_pizzas_donated
    @donated_pizzas = @pizzas ? @pizzas : 0
    @user_id = request[:id]
    @user_requests = Request.user_history(@user_id)
    @user_thank_yous = ThankYou.user_history(@user_id)
    @asset = S3_BUCKET.object('iwantpizza.mp4')
    @url = @asset.presigned_url(:get)
    @recent_successful_request = User.recent_successful_request(@user_id)
    if @user_requests.any? || @user_thank_yous.any?
      render :json => { totalDonatedPizzas: @donated_pizzas, userRequests: @user_requests, userThankYous: @user_thank_yous, url: @url, recentSuccessfulRequest: @recent_successful_request }
    else
      render :json => { totalDonatedPizzas: @donated_pizzas, userRequests: @user_requests, userThankYous: @user_thank_yous, url: @url, recentSuccessfulRequest: @recent_successful_request, errorMessage: 'You have no activity.' }
    end
  end

  def create
    @email = request[:userInfo][:email]
    @fb_userID = request[:userInfo][:id]
    @user = User.find_by(fb_userID: @fb_userID)

    if @user && User.recent_thank_you(@user.id)
      @recent_thank_you = User.recent_thank_you(@user.id)
    else
      @recent_thank_you = nil
    end
    if @user && User.received_thank_you(@user.id)
      @received_thank_you = User.received_thank_you(@user.id)
    else
      @received_thank_you = nil
    end
    if @user && User.recent_successful_request(@user.id) && User.recent_donation(@user.id)
      @active_donation = Request.active_donation(@user)
      @anon = User.find(@active_donation.creator_id)
      @anon_email = @anon.current_email

      @recent_successful_request = User.recent_successful_request(@user.id)

      render :json => { user: @user, signupEmail: @user.signup_email, currentEmail: @user.current_email, activeDonation: @active_donation, anonEmail: @anon_email, recentSuccessfulRequest: @recent_successful_request, recentThankYou: @recent_thank_you }
    elsif @user && User.recent_successful_request(@user.id)
      @recent_successful_request = User.recent_successful_request(@user.id)

      render :json => { user: @user, signupEmail: @user.signup_email, currentEmail: @user.current_email, activeDonation: nil, recentSuccessfulRequest: @recent_successful_request, recentThankYou: @recent_thank_you }
    elsif @user && User.recent_donation(@user.id)
      @active_donation = Request.active_donation(@user)

      @anon = User.find(@active_donation.creator_id)
      @anon_email = @anon.current_email

      render :json => { user: @user, signupEmail: @user.signup_email, currentEmail: @user.current_email, activeDonation: @active_donation, anonEmail: @anon_email, recentSuccessfulRequest: nil, recentThankYou: @recent_thank_you }
    elsif @user
      render :json => { user: @user, signupEmail: @user.signup_email, currentEmail: @user.current_email, activeDonation: nil, anonEmail: nil, recentSuccessfulRequest: nil, recentThankYou: @recent_thank_you }
    else
      @user = User.new(fb_userID: @fb_userID, signup_email: @email)

      if @user.save!
        render :json => { user: @user, signupEmail: @user.signup_email, currentEmail: @user.current_email, activeDonation: nil, recentSuccessfulRequest: nil, recentThankYou: @recent_thank_you }
      else
        render :json => { errorMessage: "Cannot log in" }
      end
    end
  end

  def update
    @user = User.find(request[:id])
    if @user.update(current_email: params[:updatedEmail])
      render :json => { user: @user, signupEmail: @user.signup_email, currentEmail: @user.current_email, errorMessage: "Your email was successfully updated." }
    else
      render :json => { errorMessage: "Your email was not updated.\nPlease enter a valid email address." }
    end
  end

end
