class BadgesController < ApplicationController

  def index
    @badges = Rails.cache.fetch('all_badges', expires_in: 1.hour){ Badge.all }

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @badges }
    end
  end

  def show
    @badge = Badge.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @badge }
    end
  end
end
