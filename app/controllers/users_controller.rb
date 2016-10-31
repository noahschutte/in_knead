class UsersController < ApplicationController

  def index
    @pizzas = Request.total_pizzas_donated
    render :json => { totalDonatedPizzas: @pizzas }
  end

  def show
    @user = User.find(request[:id])
    render :json => { email: @user.current_email }
  end

  def create
    @email = request[:userInfo][:email]
    @fb_userID = request[:userInfo][:id]
    @first_name = request[:userInfo][:first_name]
    @user = User.find_by(fb_userID: @fb_userID)
    if @user && User.recent_donation(@user.id)
      @active_donation = Request.active_donation(@user)
      render :json => { user: @user, email: @user.current_email, activeDonation: @active_donation[0] }
    elsif @user
      render :json => { user: @user, email: @user.current_email, activeDonation: nil }
    else
      @user = User.create(fb_userID: @fb_userID, first_name: @first_name, signup_email: @email, current_email: @email)
      render :json => { user: @user, email: @user.current_email, activeDonation: nil }
    end
  end

  def update
    @user = User.find(request[:id])
    if @user.update(current_email: params[:updatedEmail])
      render :json => { email: @user.current_email, errorMessage: "Your email was successfully updated." }
    else
      render :json => { errorMessage: "Your email was not updated.\nPlease enter a valid email address." }
    end
  end

end
