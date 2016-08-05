class CreateBoards < ActiveRecord::Migration
  def change
    create_table :boards do |t|
      t.string :x_player, null: false
      t.string :o_player, null: false
      t.string :channel_id, null: false
      t.string :status, null: false, defaut: "IP"
      t.string :winner
      t.string :grid, null: false

      t.timestamps null: false
    end
  end
end
