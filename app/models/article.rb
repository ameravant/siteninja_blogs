class Article < ActiveRecord::Base
  has_permalink :title
  acts_as_taggable
  belongs_to :article_category
  belongs_to :feed
  has_and_belongs_to_many :article_categories
  belongs_to :person, :counter_cache => true
  belongs_to :column
  has_many :comments, :as => :commentable
  has_many :images, :as => :viewable, :dependent => :destroy
  has_many :activities, :as => :loggable, :dependent => :destroy
  has_many :features, :as => :featurable, :dependent => :destroy
  has_many :assets, :as => :attachable, :dependent => :destroy
  validates_presence_of :title, :body
  accepts_nested_attributes_for :images
  validates_datetime :published_at
  named_scope :published, { :conditions => ["(published_at <= ? and published = ?) or publish_immediately = ?", Time.current, true, true] }
  named_scope :published_in_month, lambda { |month, year| {
    :conditions => { :published_at => Date.civil(year, month, 1).to_time..(Date.civil(year, month, 1) >> 1).to_time, :published => true }
    }
  }
  named_scope :recent, lambda { |amount|{ :limit => amount }}
  default_scope :order => "articles.published_at desc", :include => :person
  
  attr_accessor :lastname
  validates_format_of :lastname, :with => /\A\Z/ # must be blank
  liquid_methods :title, :author, :comments_count, :description, :blurb, :body, :show_description, :path, :list_of_article_categories, :date, :time, :article_categories if RAILS_ENV == "development"
  
  def to_param
    "#{self.id}-#{self.permalink}"
  end
  
  def path
    "/#{path_safe(CMS_CONFIG['site_settings']['article_title'])}/#{self.to_param}"
  end
  
  def date
    self.published_at.strftime("%b %d, %Y")
  end
  
  def time
    self.published_at.strftime("%I:%M %p")
  end
  
  def list_of_article_categories
    acs = self.article_category.blank? ? self.article_categories.active : self.article_categories.active.reject { |c| c.id == self.article_category_id }
    if !self.article_category.blank? or !self.article_categories.empty? 
    output = "in "
      if !self.article_category.blank?
        output += "<a href=\"/#{path_safe(CMS_CONFIG['site_settings']['article_title']).singularize}-categories/#{self.article_category.to_param}\">#{self.article_category.title}</a>" + (acs.empty? ? "" : ", ")
      end
      output += acs.map { |c| "<a href=\"/#{path_safe(CMS_CONFIG['site_settings']['article_title']).singularize}-categories/#{c.to_param}\">#{c.title}</a>" }.uniq.join(", ")
    end
  end
  
  def image_path
    if self.images_count > 0
      output = self.images.first.image.url(:medium)
    end
  end
  
  def large_image_path
    if self.images_count > 0
      output = self.images.first.image.url(:slide)
    end
  end
  
  def original_image_path
    if self.images_count > 0
      output = self.images.first.image.url(:original)
    end
  end
  
  def name
    if CMS_CONFIG['modules']['profiles']
      if self.person.blank? and self.person.profile.blank?
        self.person.name
      else
        self.person.name
      end
    elsif self.person.blank?
      self.author_name
    else
      self.person.name
    end
  end
  
  def author
    if CMS_CONFIG['modules']['profiles']
      if self.person.profile.blank?
        "<a href=\"/#{path_safe(CMS_CONFIG['site_settings']['article_title'])}?author=#{self.person.id}\">#{self.person.name}</a>"
      else
        "<a href=\"/profiles/#{self.person.profile.permalink}\">#{self.person.name}</a>"
      end
    elsif self.person.blank?
      self.author_name
    else
      "<a href=\"/#{path_safe(CMS_CONFIG['site_settings']['article_title'])}?author=#{self.person.id}\">#{self.person.name}</a>"
    end
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
  
  def is_not_by_author?
    !person.user.has_role('Author')
  end
  
  if RAILS_ENV == "production"
    def to_liquid
      {'title' => self.title, 'comments_count' => self.comments_count, 'description' => self.description, 'blurb' => self.blurb, 'body' => self.body, 'show_description' => self.show_description, 'path' => self.path, 'list_of_article_categories' => self.list_of_article_categories, 'date' => self.date, 'time' => self.time, 'article_categories' => self.article_categories, 'author' => self.author, 'image_path' => self.image_path, 'large_image_path' => self.large_image_path, 'original_image_path' => self.original_image_path }
    end
  end
end
