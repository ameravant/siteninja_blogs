class ArticleCategory < ActiveRecord::Base
  has_permalink :name
  belongs_to :column
  belongs_to :layout, :class_name => "Column", :foreign_key => :main_column_id
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
  liquid_methods :title, :path
  
  def to_param
    "#{self.id}-#{self.permalink}"
  end
  
  def path
    "#{(CMS_CONFIG['site_settings']['article_title']).singularize}-categories/#{self.to_param}"
  end
  
  def title # for model consistency, title is treated as name
    self.name
  end
  
end
