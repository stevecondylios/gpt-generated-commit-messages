class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :admin
      t.string :last_seen
      t.string :time_zone

      t.timestamps
    end
  end
end
