class CommitteesController < ApplicationController
  
  def index
    @council = Council.find(params[:council_id])
    @committees = @council.committees
  end
  
  def show
    @committee = Committee.find(params[:id])
    @council = @committee.council
    @members = @committee.members
    @meetings = @committee.meetings
  end
  
end
