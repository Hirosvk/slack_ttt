class RenameColumnCertificate < ActiveRecord::Migration
  def change
    rename_column :certificates, :type, :purpose
  end
end
