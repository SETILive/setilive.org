class ClassificationsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter

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

    signals.each do |signal|
      @classification.signals << Signal.new(signal)
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
