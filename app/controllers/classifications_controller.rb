class ClassificationsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter 
  # before_filter :check_login

  def show
    @classification = Classification.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @classification }
    end
  end


  def create
    signals         = params.delete(:signals)
    @classification = Classification.new(params[:classification])
    @classification.zooniverse_user = current_user 

    binding.pry
    if signals 
      signals.each do |signal|
        @classification.signals << SbjectSignal.new(signal)
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


end
