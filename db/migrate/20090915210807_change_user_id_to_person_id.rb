class ChangeUserIdToPersonId < ActiveRecord::Migration
  def self.up
    rename_column :articles, :user_id, :person_id
    for article in Article.all
      user = User.find_by_id(article.person_id)
      article.update_attributes(:person_id => user.person.id)
    end
  end

  def self.down
    rename_column :articles, :person_id, :user_id
    for article in Article.all
      person = Person.find_by_id(article.user_id)
      article.update_attributes(:user_id => person.user.id)
    end
  end
end
