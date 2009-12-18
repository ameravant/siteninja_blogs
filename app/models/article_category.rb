class ArticleCategory < ActiveRecord::Base
  has_permalink :name
  has_and_belongs_to_many :articles
  has_many :pages
  validates_presence_of :name
  named_scope :active, :conditions => { :active => true }
  default_scope :order => "name"
  
  def to_param
    "#{self.id}-#{self.permalink}"
  end
end
