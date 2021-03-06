class CreateRecipes < ActiveRecord::Migration[5.2]
  def change
    create_table :recipes do |t|
      t.references :user, foreign_key: true
      t.string :title
      t.text :content
      t.text :ingredients

      t.timestamps
    end
  end
end
