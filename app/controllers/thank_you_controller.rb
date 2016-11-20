class ThankYouController < ApplicationController

  def create
    p "CREATE THANK YOU"
    render :json => { errorMessage: 'create thank_you HIT.' }
  end

end
