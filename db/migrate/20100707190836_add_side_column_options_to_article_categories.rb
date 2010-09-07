class AddSideColumnOptionsToArticleCategories < ActiveRecord::Migration
  def self.up
    add_column :articles, :show_testimonials, :boolean, :default => false
    add_column :articles, :show_articles, :boolean, :default => false
    add_column :articles, :show_events, :boolean
    add_column :articles, :author_id, :integer
    add_column :articles, :article_category_id, :integer
    add_column :articles, :show_article_cats, :boolean
    add_column :articles, :show_featured_testimonial, :boolean
    add_column :articles, :show_newsletter_signup, :boolean
    add_column :articles, :side_column_content, :boolean
    add_column :articles, :show_site_search, :boolean
  end

  def self.down
    remove_column :articles, :show_site_search
    remove_column :articles, :side_column_content
    remove_column :articles, :show_newsletter_signup
    remove_column :articles, :show_featured_testimonial
    remove_column :articles, :show_article_cats
    remove_column :articles, :article_category_id
    remove_column :articles, :author_id
    remove_column :articles, :show_events
    remove_column :articles, :show_testimonials
    remove_column :articles, :show_articles
  end
end