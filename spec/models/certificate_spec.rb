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

require 'rails_helper'

RSpec.describe Certificate, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
