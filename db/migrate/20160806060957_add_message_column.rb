class AddMessageColumn < ActiveRecord::Migration
  def change
    add_column :boards, :message, :string
  end
end
