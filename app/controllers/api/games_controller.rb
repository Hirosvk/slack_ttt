class Api::GamesController < ApplicationController
  # after_filter :cors_set_access_control_headers
  #
  # def cors_set_access_control_headers
  #   headers['Access-Control-Allow-Origin'] = '*'
  #   headers['Access-Control-Allow-Methods'] = 'POST, GET'
  #   headers['Access-Control-Allow-Headers'] = %w{Origin Accept Content-Type}.join(',')
  # end
  #
  # the above code was necessary to test API from local browser,
  # but unnecessary to take requests from Slack

  DEFAULT_RESP = {
    status: 200,
    content_type: "application/json",
    json: {
      response_type: "ephemeral",
      text: nil
    }
  }

  DEFAULT_ATTACHMENT = [{
      text: nil,
      mrkdwn_in: ["text"]
  }]

  def challenge
    challenger = params[:user_name]
    challenged = params[:text].gsub(/\s+.*/, "")

    resp = dup(DEFAULT_RESP)
    team_user_status = get_team_user_status

    if !team_user_status.is_a?(Hash)
      resp[:json][:text] = team_user_status

    elsif team_user_status.keys.include?(challenged)
      if team_user_status[challenged] == "active"
        @challenge = Challenge.new(challenger: challenger,
                                   challenged: challenged,
                                   channel_id: params[:channel_id])
        if @challenge.save
          resp[:json][:text] = "#{@challenge.challenger} challenges #{@challenge.challenged} on the game of Tic-Tac-Toe.\n#{@challenge.challenged}, do you accept? (respond either with `/accept` or `/decline`)"
          resp[:json][:response_type] = "in_channel"
        else
          resp[:json][:text] = @challenge.errors[:resp].join(", ")
        end
      elsif challenged == "slackbot"
        resp[:json][:text] = "Slackbot cannot accept the challenge"
      else
        resp[:json][:text] = "#{challenged} is away and can't accept your challenge"
      end
    elsif challenged.length == 1
      resp[:json][:text] = "username is missing"
    else
      resp[:json][:text] = "#{challenged} is not a member of the team"
    end
    render resp
  end

  def accept
    @challenge = Challenge.find_challenge(params[:user_name], params[:channel_id])
    resp = dup(DEFAULT_RESP)
    if @challenge.nil?
      resp[:json][:text] = "There is no challenge to accept(challenges expire in 1 min)"
    else
      @board = @challenge.create_new_game
      if @board.save!
        resp[:json][:text] = @board.render
        resp[:json][:attachments] = attachment_text(@board.render_message)
        resp[:json][:response_type] = "in_channel"
      else
        resp[:json][:text] = @board.errors[:resp].join(",")
      end
    end
    render resp
  end

  def decline
    @challenge = Challenge.find_challenge(params[:user_name], params[:channel_id])
    resp = dup(DEFAULT_RESP)
    if @challenge.nil?
      resp[:json][:text] = "There is no challenge to decline(challenges expire in 1 min)"
    else
      @challenge.decline
      resp[:json][:text] = "#{@challenge.challenged} declined the challenge from #{@challenge.challenger}"
      resp[:json][:response_type] = "in_channel"
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
        @board.process_new_move(params[:user_name], params[:text].gsub(/\s+.*/).to_i)
        resp[:json][:text] = @board.render
        resp[:json][:attachments] = attachment_text(@board.render_message)
        resp[:json][:response_type] = "in_channel"
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
      resp[:json][:attachments] = attachment_text(@board.render_message)
    else
      resp[:json][:text] = "No game has taken place yet."
    end
    render resp
  end

  def how
    origin = request.headers.env["HTTP_ORIGIN"]
    instructions =
    "How to play a game of Tic-Tac-Toe:\n
    1. Start by challeging another user with `/challenge [username]`\n
    2. The game will begin when the other user accepts your challenge\n
    3. On your turn, place your mark with `/mark [position number]`.\n
    4. You can abandon the game any time with `/abandon`\n
    (Click <https://github.com/Hirosvk/slack_ttt|here> for more info about the game)\n
    "
    resp = dup(DEFAULT_RESP)
    resp[:json][:text] = instructions
    render resp
  end

  def abandon
    @board = Board.find_most_recent_game(params[:channel_id])
    resp = dup(DEFAULT_RESP)
    if @board && @board.status == "IP"
      if params[:user_name] == @board.x || params[:user_name] == @board.o
        @board.abandon
        resp[:json][:text] = "#{params[:user_name]} abandoned the game"
        resp[:json][:response_type] = "in_channel"
      else
        resp[:json][:text] = "Only the current players can abandon"
      end
    else
      resp[:json][:text] = "There is no game to abandon"
    end
    render resp
  end

  def check
    resp = dup(DEFAULT_RESP)

    team_user_status = get_team_user_status
    game = Board.find_most_recent_game(params[:channel_id])

    if game && game.status == "IP"
      x_active = team_user_status[game.x] == "active"
      o_active = team_user_status[game.o] == "active"
      if x_active && o_active
        resp[:json][:text] = "Everything looks fine"
      else
        resp[:json][:text] = "Looks like players have left the Slack channel! This game is now abandoned"
        resp[:json][:response_type] = "in_channel"
        game.abandon
      end
    else
      resp[:json][:text] = "no game is taking place"
    end
    render resp
  end

  def respond_ok
    render status: 200, json: "Hi Slack people!"
  end

## development purpose only ##
  # def spec
  #   render :spec_runner
  # end
  #
  # def destroy_all
  #   ## test purpose only
  #   Challenge.destroy_all
  #   Board.destroy_all
  #   resp = dup(DEFAULT_RESP)
  #   resp[:json][:text] = "All Challenges/Boards Destroyed"
  #   render resp
  # end

private
  def dup(hash)
    hash.inject({}) do |accum, (k,v)|
      accum[k] = v.is_a?(Hash) ? dup(v) : v
      accum
    end
  end

  def attachment_text(str)
    attachment = dup(DEFAULT_ATTACHMENT[0])
    attachment[:text] = str
    [attachment]
  end

  def get_team_user_status
    token = Certificate.slack_api
    api_path = "https://slack.com/api/users.list?token=#{token}&presence=1&pretty=1"
    begin
      raw_resp = HTTP.get(api_path)
    rescue HTTP::Error => e
      return e.message
    end
    members = raw_resp.parse["members"]
    if raw_resp.code != 200 || !members.is_a?(Array)
      return "Connection error: unable to verify the active users"
    else
      active_members = members.inject({}) do |accum, member|
        accum[member["name"]] = member["presence"]
        accum
      end
    end
  end

end
