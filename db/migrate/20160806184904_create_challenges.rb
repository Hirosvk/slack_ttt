class CreateChallenges < ActiveRecord::Migration
  def change
    create_table :challenges do |t|
      t.string :challenger, null: false
      t.string :challenged, null: false
      t.string :channel_id, null: false
      t.timestamps null: false
    end
  end
end
