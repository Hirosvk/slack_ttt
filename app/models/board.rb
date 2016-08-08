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
  validates :x, :o, :channel_id, :current_mark, :grid, :message, presence: true
  validates :status, inclusion: ["IP", "C"]
  after_initialize :set_initial_state

  def self.find_most_recent_game(channel)
    game_in_progress = self.where("status = ? AND channel_id = ?", "IP", channel).first
    return game_in_progress if game_in_progress

    most_recent_completed = self.where(channel_id: channel).order("created_at DESC").first
    return most_recent_completed
  end

  def abandon
    self.update!(status: "C", message: "*This game was abandoned*")
  end

  def process_new_move(player, position)
    if self.status == "C"
      raise TTTError.new("This game has already been completed or abandoned")
    end

    if !(1..9).to_a.include?(position)
      raise TTTError.new("Please enter valid a positions(between 1 and 9)")
    elsif player == next_player
      raise TTTError.new("It's not your turn!")
    elsif player != current_player
      raise TTTError.new("You are not playing this game")
    elsif player == current_player
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

    if self.status == "C" && self.updated_at <= (Time.now - 60)
      winner = winner?
      completed_at = self.updated_at.localtime.strftime("%Y-%m-%d %H:%M")
      if filled? && !winner # tie
        result += "The last game was a tie at #{completed_at}"
      elsif winner
        winner_name = self.send(winner)
        result += "The last game was won by #{winner_name} at #{completed_at}"
      else #game was abandoned
        result += "The last game was abandoned at #{completed_at}"
      end
    else
      result += self.message
    end
    result
  end

private
  ## helper methods

  def mark(position)
    new_grid = self.grid
    if new_grid[position - 1] =~ /[^1-9]/
      raise TTTError.new("That space is already marked")
    end

    new_grid[position - 1] = current_mark
    self.update!(grid: new_grid,
                 current_mark: next_mark,
                 message: "It's #{next_player}'s turn(#{next_mark})")
  end

  def check_for_winner
    winner = winner?
    if winner
      winner_name = self.send(winner)
      self.update!(status: "C",
                   winner: winner_name,
                   message: "*#{winner_name} has won!*")
    elsif filled?
      self.update!(status: "C",
                   message: "*It's a tie!*")
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
    !!(self.grid =~ /^[XO]+$/)
  end

  def next_mark
    current_mark == "O" ? "X" : "O"
  end

  def current_player
    column = current_mark == "X" ? "x" : "o"
    self.send(column)
  end

  def next_player
    column = current_mark == "O" ? "x" : "o"
    self.send(column)
  end

  ## custom_validation
  def set_initial_state
    self.grid ||= "123456789"
    self.current_mark ||= "X"
    self.status ||= "IP"
    self.message ||= "This is a new game! It's #{current_player}'s turn(#{current_mark})"
  end

  def check_players
    if self.x == self.o
      errors[:resp] << "You can't challenge yourself!"
    elsif self.x.nil? || self.x.length < 1
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

end
