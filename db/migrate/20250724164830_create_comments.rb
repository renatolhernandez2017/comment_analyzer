class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.references :post, foreign_key: true
      t.integer :external_id
      t.string :name
      t.string :email
      t.text :body
      t.text :translated_body
      t.string :status

      t.timestamps
    end
  end
end
