class Article < ActiveRecord::Base
  has_permalink :title
  acts_as_taggable
  has_and_belongs_to_many :article_categories
  belongs_to :person, :counter_cache => true
  has_many :comments
  has_many :images, :as => :viewable, :dependent => :destroy
  has_many :features, :as => :featurable, :dependent => :destroy
  has_many :assets, :as => :attachable, :dependent => :destroy
  validates_presence_of :title, :body
  named_scope :published, { :conditions => ["published_at <= ? and published = ?", Time.now, true] }
  named_scope :published_in_month, lambda { |month, year| {
    :conditions => { :published_at => Date.civil(year, month, 1).to_time..(Date.civil(year, month, 1) >> 1).to_time, :published => true }
    }
  }
  named_scope :recent, lambda { |amount|{ :limit => amount }}
  default_scope :order => "articles.published_at desc", :include => :person
  
  attr_accessor :lastname
  validates_format_of :lastname, :with => /\A\Z/ # must be blank
  
  def to_param
    "#{self.id}-#{self.permalink}"
  end
  
  def published_date_in_past?
    self.published_at <= Time.now
  end

  def to_be_published?
    self.published? and self.published_at > Time.now
  end
  
  def deactivated?
    !self.published? and self.published_date_in_past?
  end
  
  def user
    self.person.user
  end
end
