class VotesController < ApplicationController

  def create
    @vote = Vote.new params[:vote]
    if @vote.save
      redirect_to sessions_path(@vote.year)
    end
  end

  def destroy
    @vote = Vote.find params[:id]
    year = @vote.year
    if @vote.destroy
      redirect_to sessions_path(year)
    end
  end
end
