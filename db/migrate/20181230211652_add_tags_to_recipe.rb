class AddTagsToRecipe < ActiveRecord::Migration[5.2]
  def change
    add_column :recipes, :tags, :string
  end
end
