class AddProcessingStatusToKeywords < ActiveRecord::Migration[5.2]
  def change
    add_column :keywords, :processing, :boolean, default: true
  end
end
