class Api::GamesController < ApplicationController

  def spec
    render "spec_runner.html"
  end

  def challenge
    @challenge = Challenge.new(challenger: params[:user_name],
                               challenged: params[:text],
                               channel_id: params[:channel_id])
    if @challenge.save
      render json: {
        text: "#{@challenge.challenger} challenges #{@challenge.challenged} on the game of Tic-Tac-Toe.\n#{@challenge.challenged}, do you accept? (respond either with '/accept' or '/decline')",
        },
        status: 200,
        content_type: "application/json"
    else
      render json: {text: @challenge.errors[:resp].first}
    end
  end

  def accept
    render json: {text: params[:user_name]}
  end

  def destroy_all
    ## test purpose only
    Challenge.destroy_all
    Board.destroy_all
    render json: {text: "All Challenges/Boards Destroyed"}
  end
end
