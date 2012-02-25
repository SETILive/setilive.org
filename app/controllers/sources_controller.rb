class SourcesController < ApplicationController
  
  def index
    @small_star_field = true  
    sources = Source.get_cached_sources
    
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
