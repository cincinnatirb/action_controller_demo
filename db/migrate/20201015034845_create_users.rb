class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :username
      t.string :first_name
      t.string :last_name
      t.text :bio
      t.integer :bicycles
      t.float :gpa
      t.date :birth_date
      t.datetime :account_expiration
      t.boolean :earthling

      t.timestamps
    end
  end
end
