# == Schema Information
#
# Table name: boards
#
#  id           :integer          not null, primary key
#  x            :string           not null
#  o            :string           not null
#  channel_id   :string           not null
#  status       :string           not null
#  winner       :string
#  grid         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  current_mark :string           not null
#  message      :string
#

class TTTError < StandardError
end

class Board < ActiveRecord::Base
  validate :check_players, :other_game_IP?
  validates :x, :o, :channel_id, :current_mark, :grid, presence: true
  validates :status, inclusion: ["IP", "C"]
  after_initialize :set_initial_state

  def self.find_most_recent_game(channel)
    game_in_progress = self.where("status = ? AND channel_id = ?", "IP", channel).first
    return game_in_progress if game_in_progress

    most_recent_completed = self.where(channel_id: channel).order("created_at DESC").first
    return most_recent_completed
  end

  def abandon
    self.update!(status: "C", message: "This game has been abandoned")
  end

  def process_new_move(player, position)
    if self.status == "C"
      raise TTTError.new("This game has already been completed or abandoned")
    end

    whose_turn = self.send(current_player)
    if whose_turn != player
      raise TTTError.new("It's #{whose_turn}'s turn")
    else
      mark(position)
    end

    check_for_winner
  end

  def render
    game_grid = self.grid
    result = ""
    9.times do |i|
      separator = "-"
      separator = "\n" if (i+1)%3 == 0
      result += game_grid[i] + separator
    end
    msg = self.message
    result += msg if msg
    result
  end

private
  ## custom_validation
  def set_initial_state
    self.grid ||= "123456789"
    self.current_mark ||= "X"
    self.status ||= "IP"
  end

  def check_players
    if self.x == self.o
      errors[:resp] << "You can't challenge yourself!"
    elsif self.x.length < 1
      errors[:resp] << "You need to challenge another player"
    end
  end

  def other_game_IP?
    return if self.status == "C"
    games = self.class.where(channel_id: self.channel_id)
    games.each do |board|
      if board.status == "IP" && board.id != self.id
        errors[:resp] << "Only one game can take place per channel"
        break
      end
    end
  end

  ## other helper methods
  def mark(position)
    new_grid = self.grid
    if new_grid[position - 1] =~ /[^1-9]/
      raise TTTError.new("That space is already marked")
    end
    new_grid[position - 1] = current_mark
    next_mark = (current_mark == "X") ? "0" : "X"
    self.update!(grid: new_grid, current_mark: next_mark)
  end

  def check_for_winner
    winner = winner?
    if winner
      winner_name = self.send(winner)
      self.update!(status: "C",
                   winner: winner_name,
                   message: "#{winner_name} has won!")
    elsif filled?
      self.update!(status: "C",
                   message: "It's a tie!")
    end
  end

  WIN_COMBOS = [
    [0,1,2],[3,4,5],[6,7,8],
    [0,3,6],[1,4,7],[2,5,8],
    [0,4,8],[2,4,6]
  ]
  def winner?
    game_grid = self.grid
    WIN_COMBOS.each do |combo|
      if game_grid[combo[0]] == game_grid[combo[1]] &&
         game_grid[combo[1]] == game_grid[combo[2]]
        return game_grid[combo[0]] == "X" ? "x" : "o"
      end
    end
    false
  end

  def filled?
    !!(self.grid =~ /^[X0]+$/)
  end

  def current_player
    current_mark == "X" ? "x" : "o"
  end


end
