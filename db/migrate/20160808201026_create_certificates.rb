class CreateCertificates < ActiveRecord::Migration
  def change
    create_table :certificates do |t|
      t.string :type, null: false
      t.string :token, null: false
      t.string :note
      t.timestamps null: false
    end
  end
end
