class UsersController < ApplicationController

  def show
    @user = User.find(request[:id])
    @user_id = @user.id
    @user_requests = Request.user_history(@user_id)
    @user_thank_yous = ThankYou.user_history(@user_id)
    @recent_successful_requests = User.recent_successful_requests(@user_id)
    @thank_you_reminders = User.thank_you_reminders(@user_id)
    @recent_donations = User.recent_donations(@user_id)
    @awaiting_thank_yous = User.awaiting_thank_yous(@user_id)
    @received_thank_yous = User.received_thank_yous(@user_id)
    render :json => {
      currentEmail: @user.current_email,
      userRequests: @user_requests,
      userThankYous: @user_thank_yous,
      recentSuccessfulRequests: @recent_successful_requests,
      thankYouReminders: @thank_you_reminders,
      recentDonations: @recent_donations,
      awaitingThankYous: @awaiting_thank_yous,
      receivedThankYous: @received_thank_yous
    }
  end

  def create
    @email = request[:userInfo][:email]
    @fb_userID = request[:userInfo][:id]
    @user = User.find_by(fb_userID: @fb_userID)
    if !@user
      @user = User.new(fb_userID: @fb_userID, signup_email: @email)
      if !@user.save
        render :json => { errorMessage: "Cannot log in" }
      end
    end
    render :json => { user: @user }
  end

  def update
    @user = User.find(request[:id])
    if @user.update(current_email: params[:updatedEmail])
      render :status => :ok
    else
      render :json => { errorMessage: "Your email was not updated.\nPlease enter a valid email address." }
    end
  end

end
