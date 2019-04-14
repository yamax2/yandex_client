class CreateTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :tokens do |t|
      # from yandex passport info
      t.string :user_id, limit: 100, null: false
      t.string :login, limit: 255, null: false

      # yandex oauth
      t.string :access_token, limit: 100, null: false
      t.bigint :expires_in, null: false
      t.string :refresh_token, limit: 100, null: false
      t.string :token_type, limit: 20, null: false

      t.timestamps null: false
    end

    add_index :tokens, :user_id, unique: true
  end
end
