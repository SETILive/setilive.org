class ResultsController < ApplicationController
	
	
	def index 
		
	end
	
	
	def show 
		subject = Subject.find(params[:id])
		subject ||= Subject.find_by_zooniverse_id()
		respond_to do |format|
			format.html

			format.json { render json: subject.to_json(:include=>{:observations=>{:include=>{:signal_groups=>{:include=>:subject_signals, :except=> :subject_signal_ids}}}}) 
			}
		end
	end
	
end
