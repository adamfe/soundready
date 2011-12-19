class AddSetlists < ActiveRecord::Migration
  def up
    create_table :setlists do |t|
      t.string :artist_name
      t.string :artist_mbid
      t.string :tour_name
      t.date :show_date 
      t.timestamps
    end
  end

  def down
    drop_table :setlists
  end
end
