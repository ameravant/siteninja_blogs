class ArticleCategory < ActiveRecord::Base
  has_permalink :name
  has_and_belongs_to_many :articles
  has_many :pages
  has_many :features, :as => :featurable, :dependent => :destroy
  has_many :images, :as => :viewable, :dependent => :destroy
  has_many :menus, :as => :navigatable, :dependent => :destroy
  validates_presence_of :name
  named_scope :active, :conditions => { :active => true }
  default_scope :order => "name"
  
  def to_param
    "#{self.id}-#{self.permalink}"
  end
  
  def title # for model consistency, title is treated as name
    self.name
  end
  
end
