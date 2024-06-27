class CreateJoinTableQuoteTag < ActiveRecord::Migration[7.0]
  def change
    create_join_table :quotes, :tags do |t|
      # This was generated but causes ArgumentError: you can't define an already defined column 'quote_id'.
      # and you can't define an already defined column 'quote_id'.
      # t.references :quote, null: false, foreign_key: true
      # t.references :tag, null: false, foreign_key: true
      t.index :quote_id
      t.index :tag_id
    end
  end
end
