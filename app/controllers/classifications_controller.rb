class ClassificationsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::GatewayFilter , :except =>[:recent]
  before_filter :check_login, :except =>[:recent]

  def show
    @classification = Classification.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @classification }
    end
  end

  def create

    signals  = params.delete(:signals).try(:values)
    subject  = Subject.find(params.delete(:subject_id))
    
    @classification = Classification.new(:subject=>subject, :zooniverse_user => current_user)

    if signals 
      signals.each do |signal|
        characteristics  = signal['characterisations'].values
        observation = Observation.find(signal['observation_id'])
        start_coords = [signal['freqStart'],signal['timeStart']]
        end_coords   = [signal['freqEnd'],signal['timeEnd']]
        @classification.subject_signals.create(:characteristics=> characteristics, :observation_id=> observation.id, :start_coords=>start_coords,:end_coords=> end_coords)
      end
    end

    respond_to do |format|
      if @classification.save
        format.html { redirect_to @classification, notice: 'Classification was successfully created.' }
        format.json { render json: @classification, status: :created, location: @classification }
      else
        format.html { render action: "new" }
        format.json { render json: @classification.errors, status: :unprocessable_entity }
      end
    end
  end

  def classify 
    @small_star_field = true  
  end

  def recent 
    c = Classification.all(:limit=>4).to_json(:include=>{:zooniverse_user=>{:only=>:name}, :subject=>{:include => {:observations=>{:except=>:data,:include=>:source}}}})
    respond_to do |format|
       format.json { render json: c }
    end 
  end

  def tutorial
    @tutorial = true
    render :classify
  end


end
