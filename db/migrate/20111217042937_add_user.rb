class AddUser < ActiveRecord::Migration
  def up
  	create_table :users do |t|
      t.string :username
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :profile_url
      t.string :avatar_url
      t.string :account_id
      t.string :account_type
      t.string :token
      t.string :token_secret
      t.timestamps
    end
  end

  def down
    drop_table :users
  end
end
