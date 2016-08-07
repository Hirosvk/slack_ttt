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

require 'spec_helper'
require 'rails_helper'

describe Board do
  let(:empty_board){Board.create!(o: "starter", x: "challenged", channel_id: "00000")}
  let(:almost_win){
    board = Board.create!(o: "starter", x: "challenged", channel_id: "12345")
    board.process_new_move("challenged", 1)
    board.process_new_move("starter", 4)
    board.process_new_move("challenged", 5)
    board.process_new_move("starter", 7)
    board
  }
  let(:almost_tie){
    board = Board.create!(o: "starter", x: "challenged", channel_id: "67890")
    board.process_new_move("challenged", 2)
    board.process_new_move("starter", 1)
    board.process_new_move("challenged", 3)
    board.process_new_move("starter", 6)
    board.process_new_move("challenged", 4)
    board.process_new_move("starter", 7)
    board.process_new_move("challenged", 5)
    board.process_new_move("starter", 8)
    board
  }

  describe "New Game" do
    it "creates a game with two players' names, and channel id with the status 'IP'" do
      new_board = Board.new(o: "starter", x: "challenged", channel_id: "12345")
      expect{new_board.save!}.to_not raise_error
      expect(new_board.status).to eq("IP")
    end

    it "automatically generates empty 3x3 grid as string" do
      new_board = Board.new(o: "starter", x: "challenged", channel_id: "12345")
      expect(new_board.grid).to eq("123456789")
    end

    it "sets current_mark to challenged" do
      new_board = Board.new(o: "starter", x: "challenged", channel_id: "12345")
      expect(new_board.current_mark).to eq("X")
    end

    it "raises error when a player's name is missing" do
      new_board = Board.new(o: "starter", x: "", channel_id: "12345")
      expect{new_board.save!}.to raise_error(/.*You need to challenge another player.*/)
    end

    it "raises error when players names are the same" do
      new_board = Board.new(o: "starter", x: "starter", channel_id: "12345")
      expect{new_board.save!}.to raise_error(/.*You can't challenge yourself!.*/)
    end

    it "does not allow more than one game per channel at a time" do
      board1 = Board.create(o: "starter", x: "challenged", channel_id: "12345")
      board2 = Board.new(o: "player3", x: "player4", channel_id: "12345")
      expect{board2.save!}.to raise_error(/.*Only one game can take place per channel.*/)
    end

    it "allows new game for the channel as long as the past games are completed" do
      board1 = Board.create(o: "starter", x: "challenged", channel_id: "12345")
      board1.abandon
      board2 = Board.new(o: "player3", x: "player4", channel_id: "12345")
      expect{board2.save!}.to_not raise_error
    end

    it "allows one player to play multiple games in different channels" do
      board1 = Board.create(o: "starter", x: "challenged", channel_id: "12345")
      board2 = Board.new(o: "starter", x: "challenged", channel_id: "67890")
      expect{board2.save!}.to_not raise_error
    end
  end

  describe "#mark" do
    it "places the mark and updates the board" do
      empty_board.process_new_move("challenged", 7)
      expect(empty_board.grid).to eq("123456X89")
      empty_board.process_new_move("starter", 1)
      expect(empty_board.grid).to eq("O23456X89")
    end

    it "switches the current_mark" do
      empty_board.process_new_move("challenged", 7)
      expect(empty_board.current_mark).to eq("O")
      empty_board.process_new_move("starter", 1)
      expect(empty_board.current_mark).to eq("X")
    end

    it "raises error when the mark is not from the current player" do
      expect{empty_board.process_new_move("starter", 1)}.to raise_error(TTTError, "It's not your turn!")
      empty_board.process_new_move("challenged", 7)
      expect{empty_board.process_new_move("challenged", 5)}.to raise_error(TTTError, "It's not your turn!")
    end

    it "raises error if the board's status is 'C'(completed)" do
      empty_board.update!(status: "C")
      expect{empty_board.process_new_move("challenged", 7)}.to raise_error(TTTError, "This game has already been completed or abandoned")
    end

    it "raises error if player tries to mark the square that's already been marked" do
      empty_board.process_new_move("challenged", 1)
      expect{ empty_board.process_new_move("starter", 1) }.to raise_error(TTTError, "That space is already marked")
    end

    it "no winner until the game is won" do
      expect(almost_win.status).to eq("IP")
      expect(almost_win.winner).to eq(nil)

      expect(almost_tie.status).to eq("IP")
      expect(almost_tie.winner).to eq(nil)
    end

    it "if the new mark is the winning mark, sets status to 'C', and updates winner" do
      almost_win.process_new_move("challenged", 9)
      expect(almost_win.status).to eq("C")
      expect(almost_win.winner).to eq("challenged")
    end

    it "if the new mark makes the game tie, sets status to 'C', and leaves the winner as NULL" do
      almost_tie.process_new_move("challenged", 9)
      expect(almost_tie.status).to eq("C")
      expect(almost_tie.winner).to eq(nil)
    end
  end

  describe "#render" do
    it "returns the board in readable format" do
      expect(almost_win.render).to eq("X-2-3\nO-X-6\nO-8-9\nIt's challenged's turn(X)")
      # expect(almost_win.render).to eq("` X | 2 | 3 `\n` 4 | 5 | 6 `\n` 7 | 8 | 9 `\nIt's challenged's turn(X)")
      empty_board.process_new_move("challenged", 1)
      expect(empty_board.render).to eq("X-2-3\n4-5-6\n7-8-9\nIt's starter's turn(O)")
    end

    it "returns whose turn it is on the first turn" do
      expect(empty_board.render).to eq("1-2-3\n4-5-6\n7-8-9\nThis is a new game! It's challenged's turn(X)")
    end

    it "includes the winner in the response if there is a winner" do
      almost_win.process_new_move("challenged", 9)
      expect(almost_win.render).to eq("X-2-3\nO-X-6\nO-8-X\n*challenged has won!*")
    end
    it "says that it's a tie if the board is tie" do
      almost_tie.process_new_move("challenged", 9)
      expect(almost_tie.render).to eq("O-X-X\nX-X-O\nO-O-X\n*It's a tie!*")
    end

    it "if the game was won more than a minute ago, it shows the resul in the past tense" do
      almost_win.process_new_move("challenged", 9)
      two_min_ago = Time.now - 120
      almost_win.update!(updated_at: two_min_ago)
      two_min_ago_s = two_min_ago.localtime.strftime("%Y-%m-%d %H:%M:%S")
      expect(almost_win.render).to match("The last game was won by challenged at #{two_min_ago_s}")
    end

    it "if the game ended as tie more than a minute ago, it shows the result in the past tense" do
      almost_tie.process_new_move("challenged", 9)
      two_min_ago = Time.now - 120
      almost_tie.update!(updated_at: two_min_ago)
      two_min_ago_s = two_min_ago.localtime.strftime("%Y-%m-%d %H:%M:%S")
      expect(almost_tie.render).to match("The last game was a tie at #{two_min_ago_s}")
    end

    it "if the game was completed more than a minute ago, it shows the result in the past tense" do
      empty_board.abandon
      two_min_ago = Time.now - 120
      empty_board.update!(updated_at: two_min_ago)
      two_min_ago_s = two_min_ago.localtime.strftime("%Y-%m-%d %H:%M:%S")
      expect(empty_board.render).to match("The last game was abandoned at #{two_min_ago_s}")
    end

  end

  describe "::find_most_recent_game" do
    it "takes the channel id and returns the current game if any game is in progress" do
      empty_board.process_new_move("challenged", 9)
      game = Board.find_most_recent_game("00000")
      expect(game.id).to eq(empty_board.id)
    end

    it "returns most recent completed game if no game is in progress" do
      empty_board.process_new_move("challenged", 9)
      empty_board.abandon
      game = Board.find_most_recent_game("00000")
      expect(game.id).to eq(empty_board.id)
      expect(game.render).to eq("1-2-3\n4-5-6\n7-8-X\n*This game has been abandoned*")
    end

    it "returns the most recent one if there are multiple archived games" do
      empty_board.process_new_move("challenged", 9)
      empty_board.abandon
      new_board = Board.create!(x: "Bob", o: "Sally", channel_id: "00000")
      new_board.abandon

      game = Board.find_most_recent_game("00000")
      expect(game.id).to eq(new_board.id)
    end

    it "returns the current one if there are multiple archived games" do
      empty_board.process_new_move("challenged", 9)
      empty_board.abandon
      new_board = Board.create!(x: "Bob", o: "Sally", channel_id: "00000")
      new_board.abandon
      newest_board = Board.create!(x: "Sally", o: "Bob", channel_id: "00000")

      game = Board.find_most_recent_game("00000")
      expect(game.id).to eq(newest_board.id)
    end
  end

  describe "::recent_results" do
    it "returns the list of recent games of the channel"
  end

  describe "::recent_resulsts_all" do
    it "returns the list of recent games of all the channels"
  end
end
