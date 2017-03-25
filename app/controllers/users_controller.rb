class UsersController < ApplicationController

  def show
    @user = User.find(request[:id])
    @user_id = @user.id
    ThankYou.failed_upload(@user_id)
    @recent_successful_requests = User.recent_successful_requests(@user_id)
    @thank_you_reminders = User.thank_you_reminders(@user_id)
    @recent_donations = User.recent_donations(@user_id)
    @awaiting_thank_yous = User.awaiting_thank_yous(@user_id)
    @received_thank_yous = User.received_thank_yous(@user_id)
    render :json => {
      currentEmail: @user.current_email,
      signupEmail: @user.signup_email,
      recentSuccessfulRequests: @recent_successful_requests,
      thankYouReminders: @thank_you_reminders,
      recentDonations: @recent_donations,
      awaitingThankYous: @awaiting_thank_yous,
      receivedThankYous: @received_thank_yous
    }
  end

  def create
    @email = params[:userInfo][:email]
    @fb_userID = params[:userInfo][:id]
    @user = User.find_by(fb_userID: @fb_userID)
    if !@user
      @user = User.new(fb_userID: @fb_userID, signup_email: @email)
      if @user.save
        render :json => { user: @user }
      else
        render :status => 400, :json => { errorMessage: "User could not be logged in." }
      end
    else
      render :json => { user: @user }
    end
  end

  def update
    @user = User.find(request[:id])
    if @user.update(current_email: params[:updatedEmail])
      render :status => :ok
    else
      render :status => 400, :json => { errorMessage: "Your email was not updated.\nPlease enter a valid email address." }
    end
  end

end
