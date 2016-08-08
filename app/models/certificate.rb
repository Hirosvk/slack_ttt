# == Schema Information
#
# Table name: certificates
#
#  id         :integer          not null, primary key
#  purpose    :string           not null
#  token      :string           not null
#  note       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Certificate < ActiveRecord::Base
  validates :purpose, :token, presence: true

  def self.slash_command_tokens
    self.where(purpose: "slash_command").map(&:token)
  end

  def self.slack_api
    self.find_by_purpose("slack_api").token
  end
end
