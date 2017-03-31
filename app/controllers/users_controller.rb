class UsersController < ApplicationController

  def show
    @user = User.find(user_id_params[:id])
    @user_id = @user.id
    ThankYou.failed_upload(@user_id)
    @recent_successful_requests = User.recent_successful_requests(@user_id)
    @thank_you_reminders = User.thank_you_reminders(@user_id)
    @recent_donations = User.recent_donations(@user_id)
    @awaiting_thank_yous = User.awaiting_thank_yous(@user_id)
    @received_thank_yous = User.received_thank_yous(@user_id)
    @removed_requests = Request.new_removal(@user_id)
    @removed_thank_yous = ThankYou.new_removal(@user_id)
    render :json => {
      eulaAccepted: @user.eula_accepted,
      currentEmail: @user.current_email,
      signupEmail: @user.signup_email,
      recentSuccessfulRequests: @recent_successful_requests,
      thankYouReminders: @thank_you_reminders,
      recentDonations: @recent_donations,
      awaitingThankYous: @awaiting_thank_yous,
      receivedThankYous: @received_thank_yous,
      removedRequests: @removed_requests,
      removedThankYous: @removed_thank_yous
    }
  end

  def create
    @email = user_params[:email]
    @fb_userID = user_params[:id]
    @user = User.find_by(fb_userID: @fb_userID)
    unless @user
      @user = User.new(fb_userID: @fb_userID, signup_email: @email)
      unless @user.save
        render :status => 400, :json => { errorMessage: "User could not be logged in." }
      end
    end
    # session[:user_id] = @user.id
    render :json => { user: @user }
  end

  def update
    @user = User.find(user_update_params[:id])
    if user_update_params[:updatedEmail]
      unless User.update_email(@user, user_update_params[:updatedEmail])
        render :status => 400, :json => { errorMessage: "Your email was not updated.\nPlease enter a valid email address." }
      end
    elsif user_update_params[:acceptEULA]
      User.accept_eula(@user)
    end
    render :status => :ok
  end

  # def destroy
  #   @user = User.find(user_update_params[:id])
  #   session.clear
  #   render :status => :ok
  # end

  private
    def user_id_params
      params.permit(:id, user: {})
    end

    def user_params
      params.require(:userInfo).permit(:id, :email, :name, :first_name, :last_name, user: {})
    end

    def user_update_params
      params.permit(:id, :updatedEmail, :acceptEULA, user: {})
    end

end
