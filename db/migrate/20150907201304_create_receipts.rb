class CreateReceipts < ActiveRecord::Migration
  def change
    create_table :receipts do |t|
      t.string :title
      t.string :img
      t.text :top_tags
      t.text :tags
      t.text :ingredients

      t.timestamps null: false
    end
  end
end
