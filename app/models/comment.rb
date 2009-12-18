class Comment < ActiveRecord::Base
  belongs_to :article, :counter_cache => true
  belongs_to :user, :counter_cache => true
  validates_presence_of :name, :comment
  validates_format_of :email, :with => /\A\S+\@\S+\.\S+\Z/, :allow_blank => true
  default_scope :order => "created_at"
end
