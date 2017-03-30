class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
    @user_id = @user.id
    ThankYou.failed_upload(@user_id)
    @recent_successful_requests = User.recent_successful_requests(@user_id)
    @thank_you_reminders = User.thank_you_reminders(@user_id)
    @recent_donations = User.recent_donations(@user_id)
    @awaiting_thank_yous = User.awaiting_thank_yous(@user_id)
    @received_thank_yous = User.received_thank_yous(@user_id)
    render :json => {
      eulaAccepted: @user.eula_accepted,
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
      @user = User.new(user_params)
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
    @user = User.find(params[:id])
    if params[:updatedEmail]
      if User.update_email(@user, params[:updatedEmail])
        render :status => :ok
      else
        render :status => 400, :json => { errorMessage: "Your email was not updated.\nPlease enter a valid email address." }
      end
    elsif params[:acceptEULA]
      User.accept_eula(@user)
      render :status => :ok
    end
  end

  private
    def user_params
      params.require(:fb_userID, :signup_email)
    end

end
