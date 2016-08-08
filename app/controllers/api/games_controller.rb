class Api::GamesController < ApplicationController
  after_filter :cors_set_access_control_headers

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET'
    puts headers
  end

  DEFAULT_RESP = {
    status: 200, content_type: "application/json", json: {text: nil}
  }

  def challenge
    @challenge = Challenge.new(challenger: params[:user_name],
                               challenged: params[:text],
                               channel_id: params[:channel_id])
    resp = dup(DEFAULT_RESP)
    # debugger if params[:user_name] == "Jesse"
    if @challenge.save
      resp[:json][:text] = "#{@challenge.challenger} challenges #{@challenge.challenged} on the game of Tic-Tac-Toe.\n#{@challenge.challenged}, do you accept? (respond either with '/accept' or '/decline')"
    else
      resp[:json][:text] = @challenge.errors[:resp]
    end
    render resp
  end

  def accept
    @challenge = Challenge.find_challenge(params[:user_name], params[:channel_id])
    resp = dup(DEFAULT_RESP)
    if @challenge.nil?
      resp[:json][:text] = "There is no challenge to accept"
    else
      @board = @challenge.create_new_game
      if @board.save!
        resp[:json][:text] = @board.render
      else
        resp[:json][:text] = @board.errors[:resp]
      end
    end
    render resp
  end

  def decline
    @challenge = Challenge.find_challenge(params[:user_name], params[:channel_id])
    resp = dup(DEFAULT_RESP)
    if @challenge.nil?
      resp[:json][:text] = "There is no challenge to decline"
    else
      @challenge.decline
      resp[:json][:text] = "#{@challenge.challenged} declined the challenge from #{@challenge.challenger}"
    end
    render resp
  end

  def mark
    @board = Board.find_most_recent_game(params[:channel_id])
    resp = dup(DEFAULT_RESP)
    begin
      if @board.nil?
        resp[:json][:text] = "There is no game in progress"
      else
        @board.process_new_move(params[:user_name], params[:text].to_i)
        resp[:json][:text] = @board.render
      end
    rescue TTTError => e
      resp[:json][:text] = e.message
    end
    render resp
  end

  def show_board
    @board = Board.find_most_recent_game(params[:channel_id])
    resp = dup(DEFAULT_RESP)
    if @board
      resp[:json][:text] = @board.render
    else
      resp[:json][:text] = "No game has taken place yet."
    end
    render resp
  end

  def help
  end

  def abandon
    @board = Board.find_most_recent_game(params[:channel_id])
    resp = dup(DEFAULT_RESP)
    if @board && @board.status == "IP"
      if params[:user_name] == @board.x || params[:user_name] == @board.o
        @board.abandon
        resp[:json][:text] = "#{params[:user_name]} abandoned the game"
      else
        resp[:json][:text] = "Only the current players can abandon"
      end
    else
      resp[:json][:text] = "There is no game to abandon"
    end
    render resp
  end

## development purpose only ##
  def spec
    render :spec_runner
  end

  def destroy_all
    ## test purpose only
    Challenge.destroy_all
    Board.destroy_all
    resp = dup(DEFAULT_RESP)
    resp[:json][:text] = "All Challenges/Boards Destroyed"
    render resp
  end

  def dup(hash)
    hash.inject({}) do |accum, (k,v)|
      accum[k] = v.is_a?(Hash) ? dup(v) : v
      accum
    end
  end

end
