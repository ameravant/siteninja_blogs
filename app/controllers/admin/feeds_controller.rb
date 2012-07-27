class Admin::FeedsController < AdminController
  unloadable

  def index
    add_breadcrumb @cms_config['site_settings']['blog_title'], admin_articles_path
    add_breadcrumb "RSS Feeds"
    @feeds = Feed.all
  end
  
  def new
    add_breadcrumb @cms_config['site_settings']['blog_title'], admin_articles_path
    add_breadcrumb "RSS Feeds", admin_feeds_path
    add_breadcrumb "New RSS Feed"
    @feed = Feed.new
  end
  
  def edit
    add_breadcrumb @cms_config['site_settings']['blog_title'], admin_articles_path
    add_breadcrumb "RSS Feeds", admin_feeds_path
    @feed = Feed.find(params[:id])
    add_breadcrumb @feed.title
  end
  
  def show
    add_breadcrumb @cms_config['site_settings']['blog_title'], admin_articles_path
    add_breadcrumb "RSS Feeds", admin_feeds_path
    @feed = Feed.find(params[:id])
    add_breadcrumb @feed.title
    @article = Article.new
    begin
      open(@feed.url.gsub("feed://", "http://")) do |http|
        response = http.read
        result = RSS::Parser.parse(response, false)
      end
    rescue Exception => exc
      flash[:error] = "The URL provided was not able to be read by our RSS Parser."
    end
  end
  
  def create
    @feed = Feed.new(params[:feed])
    if @feed.save
      redirect_to admin_feed_path(@feed.id)
    else
      render :action => "new"
    end
  end
  
  def destroy
    @feed = Feed.find(params[:id])
    @feed.destroy
    respond_to :js
  end
  
  def update
    @feed = Feed.find(params[:id])
    @feed.update_attributes(params[:feed])
    redirect_to admin_feeds_path
  end
  
  def create_article
    @article = Article.new(params[:article])
    params[:article][:article_category_ids] ||= []
    params[:article][:article_category_ids] = params[:article][:article_category_ids] << @article.article_category_id unless @article.article_category_id.blank?
    @article.body = "<div>&nbsp;</div>" if @article.body.blank?
    if @article.save
      flash[:notice] = "Article \"#{@article.title}\" created."
    end
  end
  
end