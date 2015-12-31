class CreateApiKeys < ActiveRecord::Migration[5.0]
  def change
    create_table :api_keys do |t|
      t.string :access_token
      t.datetime :expires_at
      t.integer :user_id
      t.boolean :active

      t.timestamps
    end
  end
end
