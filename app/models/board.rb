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

class Board < ActiveRecord::Base
  validates :x_player, :o_player, :channle_id, presence: true
  validates :status, inclusion: ["IP", "C"]
  

end
