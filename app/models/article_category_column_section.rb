class ArticleCategoryColumnSection < ActiveRecord::Base
  belongs_to :column_section
  belongs_to :article_category
  default_scope :order => :sort_order
end
