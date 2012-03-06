class WorkflowsController < ApplicationController

   def index
    @workflows = Workflow.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @workflows }
    end
  end

  def active_workflow 
    respond_to do |format|
      format.json { render json: Workflow.active_workflow }
    end
  end

  def show
    @workflow = Workflow.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @workflow }
    end
  end
  
end
