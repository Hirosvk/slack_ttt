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

class Challenge < ActiveRecord::Base
  validates :challenger, :challenged, :channel_id, :presence => true
  validate :check_players, :game_IP?, :pending_challenges?

  def self.find_valid_challenge(challenged_player, channel)
    one_min_ago = Time.now - 60
    games = self.where("challenged = ?
                        AND channel_id = ?
                        AND created_at >= ?",
                        challenged_player, channel, one_min_ago)
    games.first
  end

  def create_new_game
    new_game = Board.new(x: challenged, o: challenger, channel_id: channel_id)
    self.destroy!
    new_game
  end

  def decline
    self.destroy!
  end

private
  def check_players
    if self.challenger == self.challenged
      errors[:resp] << "You can't challenge yourself!"
    elsif self.challenged.nil? || self.challenged.length < 1
      errors[:resp] << "You need to challenge another player"
    end
  end

  def game_IP?
    game = Board.find_most_recent_game(self.channel_id)
    if game && game.status == "IP"
      errors[:resp] << "Only one game can take place per channel"
    end
  end

  def pending_challenges?
    one_min_ago = Time.now - 60
    challenge = self.class.where("channel_id = ?
                        AND created_at >= ?",
                        self.channel_id, one_min_ago).first
    if challenge && self.id != challenge.id
      errors[:resp] << "You cannot start a new game while there is a pending challenge"
    end
  end
end
