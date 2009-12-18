class ArticlesController < ApplicationController
  unloadable # http://dev.rubyonrails.org/ticket/6001
  before_filter :find_page
  before_filter :find_article, :only => [ :show, :comment ]
  before_filter :find_articles_for_sidebar
  add_breadcrumb "Home", "root_path"

  def index
    if !params[:tag].blank?
      # Filter articles by tag
      found_articles = Article.published.find_tagged_with(params[:tag])
      add_breadcrumb "#{@cms_config['site_settings']['blog_title']}", articles_path
      add_breadcrumb params[:tag]
    elsif !params[:author].blank?
      # Filter articles by user
      @author = Person.find(params[:author])
      found_articles = @author.articles.published
      add_breadcrumb @cms_config['site_settings']['blog_title'], articles_path
      add_breadcrumb @author.name
    elsif !params[:month].blank? and !params[:year].blank?
      # Filter articles by month published
      found_articles = Article.published_in_month(params[:month].to_i, params[:year].to_i)
      add_breadcrumb "#{@cms_config['site_settings']['blog_title']}", articles_path
      add_breadcrumb "#{Date::MONTHNAMES[params[:month].to_i]} #{params[:year]}"
    else
      add_breadcrumb "#{@cms_config['site_settings']['blog_title']}"
      found_articles = Article.published
    end
    @articles = found_articles.paginate(:page => params[:page], :per_page => 10, :include => :article_categories)
    respond_to do |wants|
      wants.html # index.html.erb
      wants.xml { render :xml => @articles.to_xml }
      wants.rss { render :layout => false } # uses index.rss.builder
    end
  end

  def show
    @comment = Comment.new
    @comment.email = current_user.email if logged_in?
    @images = @article.images
    add_breadcrumb @cms_config['site_settings']['blog_title'], 'blog_path'
    add_breadcrumb @article.title
  end

  def comment
    if params[:lastname] == ""
      @comment = @article.comments.new(params[:comment])
      @comment.user_id = current_user.id if logged_in?
      add_breadcrumb @cms_config['site_settings']['blog_title'], 'blog_path'
      add_breadcrumb @article.title
      if @comment.save
        flash[:newcomment] = "Thanks for posting a comment!"
        redirect_to article_path(@article, :anchor => "newcomment")
      else
        render :action => "show"
      end
    else
      redirect_to @article
    end
  end


  private

  def find_article
    begin
      @article = Article.published.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to articles_path
    end
  end

  def find_page
    @page = Page.find_by_permalink!('blog')
  end

  def find_articles_for_sidebar
    @article_categories = ArticleCategory.active
    @article_archive = Article.published.group_by { |a| [a.published_at.month, a.published_at.year] }
    @article_authors = Person.active.find(:all, :conditions => "articles_count > 0")
    @article_tags = Article.published.tag_counts.sort_by(&:name)
  end

end

