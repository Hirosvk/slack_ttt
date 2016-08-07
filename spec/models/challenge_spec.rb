# == Schema Information
#
# Table name: challenges
#
#  id         :integer          not null, primary key
#  challenger :string           not null
#  challenged :string           not null
#  channel_id :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Challenge, type: :model do
  subject(:challenge){Challenge.new(challenger: "Sally", challenged: "Aki", channel_id: "12345")}
  let(:another_challenge){Challenge.new(challenger: "Pranav", challenged: "Aki", channel_id: "12345")}
  let(:Board){double("class_Board")}
  let(:game_board){instance_double("Board", status: "IP")}

  describe "::initalize" do
    it "inializes with challenger's name, challenged users' name, and channel_id" do
      expect{challenge.save!}.to_not raise_error
      expect(challenge.challenger).to eq("Sally")
      expect(challenge.challenged).to eq("Aki")
      expect(challenge.channel_id).to eq("12345")
    end

    it "allows only one challenge per channel" do
      challenge.save!
      expect{another_challenge.save!}.to raise_error(/.*You cannot start a new game while there is a pending challenge.*/)
    end

    it "allows to challenge another player with expired challenges" do
      challenge.save!
      challenge.update!(created_at: (Time.now - 120))

      expect{another_challenge.save!}.to_not raise_error
    end

    it "does not allow to challenge while there is a game in progress" do
      allow(Board).to receive(:find_most_recent_game).with("12345").and_return(game_board)
      expect{challenge.save!}.to raise_error(/.*Only one game can take place per channel.*/)

    end

    it "raise error if the opponent's name is missing" do
      wrong_challenge = Challenge.new(challenger: "Taki", challenged: "", channel_id: "12345")
      expect{wrong_challenge.save!}.to raise_error(/.*You need to challenge another player.*/)
    end

    it "raises error if the challenger and the challenged are the same player" do
      wrong_challenge = Challenge.new(challenger: "Taki", challenged: "Taki", channel_id: "12345")
      expect{wrong_challenge.save!}.to raise_error(/.*You can't challenge yourself!.*/)
    end

  end

  describe "::find_challenge" do
    it "returns a challenge made within the last 1 minute" do
      another_challenge.save!
      another_challenge.update!(created_at: (Time.now - 120))
      challenge.save!
      found = Challenge.find_challenge("Aki","12345")
      expect(found).to_not eq(nil)
      expect(found.id).to eq(challenge.id)
    end
    it "returns nil if no challenges were found" do
      found = Challenge.find_challenge("Aki", "12345")
      expect(found).to eq(nil)

      another_challenge.save!
      another_challenge.update!(created_at: (Time.now - 120))
      found = Challenge.find_challenge("Aki", "12345")
      expect(found).to eq(nil)
    end
  end

  describe "create_new_game (called upon accept)" do
    it "creates a new game, and return the game" do
      challenge.save!
      allow(Board).to receive(:new).and_return(game_board)
      expect(Board).to receive(:new).with(o: "Sally", x: "Aki", channel_id: "12345")
      new_game = challenge.create_new_game
      expect(new_game.status).to eq("IP")
    end
    it "destroy the challenge" do
      challenge.save!
      expect(Challenge.find_challenge("Aki", "12345")).to_not eq(nil)
      challenge.create_new_game
      expect(Challenge.find_challenge("Aki", "12345")).to eq(nil)
    end
  end

  describe "decline" do
    it "destroy the challenge" do
      challenge.save!
      expect(Challenge.find_challenge("Aki", "12345")).to_not eq(nil)
      challenge.decline
      expect(Challenge.find_challenge("Aki", "12345")).to eq(nil)
    end

    it "doesn't create a new game" do
      challenge.save!
      expect(Board).to_not receive(:new)
      challenge.decline
    end
  end

end
