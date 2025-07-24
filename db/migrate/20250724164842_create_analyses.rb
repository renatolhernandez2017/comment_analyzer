class CreateAnalyses < ActiveRecord::Migration[5.2]
  def change
    create_table :analyses do |t|
      t.references :user, foreign_key: true
      t.integer :approved_count
      t.integer :rejected_count
      t.jsonb :stats

      t.timestamps
    end
  end
end
