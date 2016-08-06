class ChangeColumnName < ActiveRecord::Migration
  def change
    rename_column :boards, :x_player, :x
    rename_column :boards, :o_player, :o
  end
end
