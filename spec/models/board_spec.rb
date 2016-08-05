# == Schema Information
#
# Table name: boards
#
#  id         :integer          not null, primary key
#  x_player   :string           not null
#  o_player   :string           not null
#  channel_id :string           not null
#  status     :string           not null
#  winner     :string
#  grid       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'
require 'rails_helper'

describe Board do
  describe "New Game" do
    it "creates a game with two players' names, and channel id with the status 'IP'" do
      new_board = Board.new("player1", "player2", "12345")
      expect(new_board.save!).to_not raise_error
      expect(new_board.status).to eq("IP")
    end

    it "automatically generates empty 3x3 grid" do
      new_board = Board.new("player1", "player2", "12345")
      expect(new_board.grid).to eq("bbbbbbbbb")
    end

    it "raises error when a player's name is missing" do
      new_board = Board.new("player1", "", "12345")
      expect(new_board.save!).to raise_error("You need to challenge another player")
    end

    it "raises error when players names are the same" do
      new_board = Board.new("player1", "player1", "12345")
      expect(new_board.save!).to raise_error("you can't challenge yourself!")
    end

    it "does not allow more than one game per channel at a time" do
      board1 = Board.create("player1", "player2", "12345")
      board2 = Board.new("player3", "player3", "12345")
      expect(board2.save!).to raise_error("Only one game can take place per channel")
    end

    it "allows one player to play multiple games in different channels" do
      board1 = Board.create("player1", "player2", "12345")
      board2 = Board.new("player1", "player2", "67890")
      expect(board2.save!).to_not raise_error
    end
  end

  describe "#mark" do
    let(:empty_board){Board.create("player1", "player2", "12345")}

    it "places the mark and updates the board" do
      empty_board.move("player1", [2,0])
      expect(empty_board.gird).to eq("bbbbbbxbb")
      empty_board.move("player2", [0,0])
      expect(empty_board.gird).to eq("obbbbbxbb")
    end

    it "raises error when the move is not from the current player" do
      empty_board.move("player1", [2,0])
      expect{empty_board.move("player1", [0,0])}.to raise_error("It's player2's turn")
    end

    it "raises error if the board's status is 'C'(completed)"
    it "if the new mark is a winning move, sets status to 'C', and updates winner"
    it "if the new mark make the game tie, sets status to 'C', and leaves the winner to NULL"

  end

  describe "#render" do
    it "returns the current board of the channel"
    it "returns a message if no game is in progress for the channel"
    it "includes the winner in the response if there is a winner"
    it "says that it's a tie if the board is tie"
  end

  describe "#abandon" do
    it "sets the game's status to 'C'"
  end

  describe "#winner?" do
    it "returns the winner's username if the game has been won"
    it "returns nil if there is no winner"
  end

  describe "#tie?" do
    it "returns true if the game is tie(all spaces filled with no winner)"
    it "returns false if the game is in progress"
  end

  describe "::render_last_game" do
    it "renders the most recent completed game's board"
  end

  describe "::get_current_game" do
    it "returns the board of the channel's current game"
  end



  # describe "::recent_results" do
  #   it "returns the list of recent games of the channel"
  # end
  #
  # describe "::recent_resulsts_all" do
  #   it "returns the list of recent games of all the channels"
  # end
end
