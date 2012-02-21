class SourcesController < ApplicationController
  
  def index
    @small_star_field = true  
    sources = Rails.cache.fetch('sources', :expires_in => 1.day){ Source.all.to_json }
    
    respond_to do |format|
      format.html # index.html.erb
      format.json {render :json => sources }
    end
  end

  def show
    @source = Source.find(params[:id])
    @small_star_field = true  

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @source }
    end
  end

  def active_sources 
    Source.active
  end

  def current_source 
    Source.current
  end


end
