class ArticleCategoriesController < ApplicationController
  unloadable
  add_breadcrumb 'Home', 'root_path'
  before_filter :add_crumbs
  before_filter :find_page
  before_filter :find_articles_for_sidebar
  before_filter :get_article_category_or_404

  def show
    begin
      @article_category = ArticleCategory.active.find(params[:id])
      @page = Page.find_by_permalink!('blog')# if @article_category.menus.empty?
      @tmplate = @page.template unless @page.template.blank?
      @tmplate.layout_top = @global_template.layout_top if @tmplate.layout_top.blank?
      @tmplate.layout_bottom = @global_template.layout_bottom if @tmplate.layout_bottom.blank?
      @tmplate.article_show = @global_template.article_show if @tmplate.article_show.blank?
      @tmplate.articles_index = @global_template.articles_index if @tmplate.articles_index.blank?
      @tmplate.small_article_for_index = @global_template.small_article_for_index if @tmplate.small_article_for_index.blank?
      @tmplate.medium_article_for_index = @global_template.medium_article_for_index if @tmplate.medium_article_for_index.blank?
      @tmplate.large_article_for_index = @global_template.large_article_for_index if @tmplate.large_article_for_index.blank?
      @side_column_sections = ColumnSection.all(:conditions => {:column_id => @article_category.column_id, :visible => true})
      @article_category.menus.empty? ? @menu = @page.menus.first : @menu = @article_category.menus.first
      @articles = @article_category.articles.published.paginate(:page => params[:page], :per_page => 10, :include => :article_categories)
      add_breadcrumb @article_category.name
    end
    respond_to do |wants|
      wants.html # index.html.erb
      wants.xml { render :xml => @articles.to_xml }
      wants.rss { render :layout => false } # uses index.rss.builder
    end
  end

  private

  def add_crumbs
    add_breadcrumb @cms_config['site_settings']['blog_title'], 'blog_path'
  end

  def find_page
    @footer_pages = Page.find(:all, :conditions => {:show_in_footer => true}, :order => :footer_pos )
    #@page = Page.find_by_permalink!('blog')
  end

  def find_articles_for_sidebar
    @article_categories = ArticleCategory.active
    @article_archive = Article.published.group_by { |a| [a.published_at.month, a.published_at.year] }
    @article_authors = Person.active.find(:all, :conditions => "articles_count > 0")
    @article_tags = Article.published.tag_counts.sort_by(&:name)
  end
  def get_article_category_or_404
    render_404 unless @article_category = ArticleCategory.active.find(params[:id])
  end
end

