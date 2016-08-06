class ChangeColumnname < ActiveRecord::Migration
  def change
    rename_column :boards, :current_player, :current_mark
  end
end
