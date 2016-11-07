class AnonController < ApplicationController

  def show
    @anon_id = request[:id]
    @anon_history = Request.anon_history(@anon_id)
    
    if @anon_history.any?
      render :json => { anonHistory: @anon_history }
    else
      render :json => { errorMessage: 'No activity.' }
    end
  end

end
