class FavouritesController < ApplicationController
  def create
    user = current_user
    observation = Observation.find(params[:observation_id])

    respond_to do |format|
      if observation and user.add_to_set(:favourite_ids=>observation.id)
        format.json { render json: user.as_json, status: :created}
      else
        format.json { render json: '', status: :unprocessable_entity }
      end
    end
  end

  def destroy
    user = current_user
    observation = Observation.find(params[:id])
    respond_to do |format|
      if observation and user.pull(:favourite_ids=>observation.id)
        format.json {render json: user.as_json, status: '200' }
      else
        format.json { render json: '', status: :unprocessable_entity }
      end
    end
  end

end
