class ArticlesController < ApplicationController
  unloadable # http://dev.rubyonrails.org/ticket/6001
  before_filter :find_article, :only => [ :show, :comment ]
  before_filter :find_page
  before_filter :authenticate, :only => :show
  #before_filter :find_articles_for_sidebar
  add_breadcrumb "Home", "root_path"

  def index
      @body_id = "articles-index-body"
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
        #if MULTI_TENANT
        #  found_articles = Account.find($CURRENT_ACCOUNT.id).articles.published
        #else
          found_articles = Article.published.reject{|x| x.published != true}
        #end
      end
      # if ActiveRecord::Base.connection.tables.include?("accounts")
      #         @articles = found_articles.reject{|a| a.account_id != $CURRENT_ACCOUNT.id}.paginate(:page => params[:page], :per_page => 10, :include => :article_categories)
      #       else
        @articles = found_articles.paginate(:page => params[:page], :per_page => 10)#, :include => :article_categories)
      # end
      @side_column_sections = ColumnSection.all(:conditions => {:column_id => @page.column_id, :visible => true})
      respond_to do |wants|
        wants.html # index.html.erb
        wants.xml { render :xml => @articles.to_xml }
        wants.rss { render :layout => false } # uses index.rss.builder
      end

  end

  def show
    @body_id = "article-#{path_safe(@article.title)}-body"
    @article_category = @article.article_category || @article.article_categories.first
    @article.article_category.blank? ? @side_column_sections = ColumnSection.all(:conditions => {:column_id => @page.column_id, :visible => true}) : @side_column_sections = ColumnSection.all(:conditions => {:column_id => @article.article_category.column_id, :visible => true})
    @images = @article.images
    add_breadcrumb @cms_config['site_settings']['blog_title'], 'blog_path'
    add_breadcrumb @article.article_category.title, @article.article_category unless @article.article_category.blank?
    add_breadcrumb '@article.title'
  end

  def articles_for_ajax
    render :layout => false
  end

  private

  def find_article
    begin
      @article = Article.find(params[:id])
      @article_category = ArticleCategory.find(@article.article_category_id) unless @article.article_category_id.blank?
      @owner = @article
    rescue ActiveRecord::RecordNotFound
      redirect_to articles_path
    end
  end

  def find_page
    @page = Page.find_by_permalink!('blog')
    @body_class = "blog-body"
    @tmplate = @page.template unless @page.template.blank?
    @tmplate.layout_top = @global_template.layout_top if @tmplate.layout_top.blank?
    @tmplate.layout_bottom = @global_template.layout_bottom if @tmplate.layout_bottom.blank?
    @tmplate.template_html.articles_index = @global_template.template_html.articles_index if @tmplate.template_html.articles_index.blank?
    @tmplate.template_html.article_show = @global_template.template_html.article_show if @tmplate.template_html.article_show.blank?
    @tmplate.template_html.small_article_for_index = @global_template.template_html.small_article_for_index if @tmplate.template_html.small_article_for_index.blank?
    @tmplate.template_html.medium_article_for_index = @global_template.template_html.medium_article_for_index if @tmplate.template_html.medium_article_for_index.blank?
    @tmplate.template_html.large_article_for_index = @global_template.template_html.large_article_for_index if @tmplate.template_html.large_article_for_index.blank?
    @menu = @page.menus.first
    @main_column = ((@page.main_column_id.blank? or Column.find_by_id(@page.main_column_id).blank?) ? Column.first(:conditions => {:title => "Default", :column_location => "main_column"}) : Column.find(@page.main_column_id))
    @main_column = Column.find(@tmplate.article_layout_id) if @article and !@tmplate.article_layout_id.blank?
    @main_column_sections = ColumnSection.all(:conditions => {:column_id => @main_column.id, :visible => true, :column_section_id => nil})
  end

  def find_articles_for_sidebar
    @article_categories = ArticleCategory.active
    @article_archive = Article.published.group_by { |a| [a.published_at.month, a.published_at.year] }
    @article_authors = Person.active.find(:all, :conditions => "articles_count > 0")
    @article_tags = Article.published.tag_counts.sort_by(&:name)
  end

  def authenticate
    if @cms_config['modules']['members'] && @article_category && @article_category.permission_level != "everyone"
      session[:redirect] = request.request_uri
      unless @article_category.blank?
        authorize(@article_category.person_groups.collect{|p| p.title}, @article_category.title)
      end
    end
  end

end

