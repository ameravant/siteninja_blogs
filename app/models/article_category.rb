class ArticleCategory < ActiveRecord::Base
  has_permalink :name
  belongs_to :column
  has_many :articles
  has_and_belongs_to_many :articles
  has_many :pages
  has_many :features, :as => :featurable, :dependent => :destroy
  has_many :images, :as => :viewable, :dependent => :destroy
  has_many :menus, :as => :navigatable, :dependent => :destroy
  has_many :article_category_column_sections
  has_many :column_sections, :through => :article_category_column_sections
  validates_presence_of :name
  named_scope :active, :conditions => { :active => true }
  default_scope :conditions => { :active => true }, :order => "name"
  
  def to_param
    "#{self.id}-#{self.permalink}"
  end
  
  def title # for model consistency, title is treated as name
    self.name
  end
  
end
