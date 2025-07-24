class CreateKeywords < ActiveRecord::Migration[5.2]
  def change
    unless table_exists?(:keywords)
      create_table :keywords do |t|
        t.string :word

        t.timestamps
      end
    end
  end
end
