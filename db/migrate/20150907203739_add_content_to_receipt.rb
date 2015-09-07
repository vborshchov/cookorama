class AddContentToReceipt < ActiveRecord::Migration
  def change
    add_column :receipts, :content, :text
  end
end
