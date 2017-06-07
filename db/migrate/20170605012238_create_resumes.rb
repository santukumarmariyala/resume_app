class CreateResumes < ActiveRecord::Migration[5.1]
  def change
    create_table :resumes do |t|
      t.string :name
      t.string :technology
      t.string :degree
      t.string :tenth_percentage
      t.string :plus_two_percentage
      t.string :graduation_percentage
      t.string :pg_percentage
      t.text :projects
      t.string :phone
      t.string :email

      t.timestamps
    end
  end
end
