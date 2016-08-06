class AddCurrentPlayer < ActiveRecord::Migration
  def change
    add_column :boards, :current_player, :string, null: false
  end
end
