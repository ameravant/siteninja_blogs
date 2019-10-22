class Admin::ArticlesController < AdminController
  unloadable # http://dev.rubyonrails.org/ticket/6001
  before_filter :authorization
  before_filter :assign_authors, :only => [:edit, :new, :create, :update]
  before_filter :find_article, :only => [ :edit, :update, :destroy, :reorder, :show ]
  before_filter :find_article_categories_and_check_roles, :only => [ :new, :create, :edit, :update ]
  before_filter :authorize_to_update, :only => [:edit, :update, :destroy]
  def index
    if params[:clear_cache]
      for article in Article.all
        begin
          expire_fragment("article-for-list-#{@article.id}")
        rescue
          # Do Nothing
        end
      end
      flash[:notice] = "Article fragment caches cleared."
      redirect_to admin_articles_path
    end
    add_breadcrumb @cms_config['site_settings']['blog_title']
    session[:redirect_path] = admin_articles_path
    if current_user.has_role(["Admin", "Editor", "Moderator"]) # Show all articles regardless of author
      params[:q].blank? ? @all_articles = Article.all : @all_articles = Article.find(:all, :conditions => ["title like ?", "%#{params[:q]}%"])
    else
      params[:q].blank? ? @all_articles = Article.all(:conditions => {:person_id => current_user.person.id}) : @all_articles = Article.find(:all, :conditions => ["title like ?", "%#{params[:q]}%"])
    end
    @articles = @all_articles.paginate(:page => params[:page], :per_page => 50)
  end

  def show
    add_breadcrumb @cms_config['site_settings']['blog_title'], admin_articles_path
    add_breadcrumb @article.title
    @images = @article.images.find :all, :order => "position"
  end

  def new
    add_breadcrumb @cms_config['site_settings']['blog_title'], admin_articles_path
    add_breadcrumb "New"
    # The following line allows an Editor or Administrator to save an article as a different person
    @editor ? (@article = Article.new) : (@article = current_user.person.articles.build)
    @article.publish_immediately = true if current_user.has_role(["Admin", "Editor", "Author"])
  end

  def edit
    add_breadcrumb @cms_config['site_settings']['blog_title'], admin_articles_path
    add_breadcrumb "Edit"
    unless @article.person.blank?
      if !@article.person.user.has_role('Author') and current_user != @article.user
        @possible_authors << @article.person      
      end
    end
    if !current_user.has_role('Author')
      @possible_authors << current_user.person
    end
  end

  def create
    #expire_fragment(/article\S*/)
    #expire_fragment(/cache_articles_for_main_column_\S*/)
    # The following line allows an Editor or Administrator to save an article as a different person
    @editor ? (@article = Article.new(params[:article])) : (@article = current_user.person.articles.build(params[:article]))
    @article.published = false unless current_user.has_role(["Admin", "Editor", "Author"])
    @article.published_at = Time.now if @article.publish_immediately == true
    #this makes sure the main article category is also in the habtm relationship so it will scope correctly
    @article.article_category_ids << @article.article_category_id unless @article.article_category_id.blank?
    if @article.save
      ac_ids = @article.article_category_ids.uniq
      ac_ids << params[:article][:article_category_id]
      ac_ids = ac_ids.uniq
      #@article.article_category_ids = []
      @article.article_category_ids = ac_ids
      flash[:notice] = "Article \"#{@article.title}\" created."
      log_activity("Created \"#{@article.title}\"")
      session[:cache] = true
      redirect_to admin_articles_path
    else
      render :action => "new"
    end
  end

  def reorder
    params["images"].each_with_index do |id, position|
      Image.update(id, :position => position + 1)
    end
    render :nothing => true
  end

  def update
    #expire_fragment(/article\S*/)
    #expire_fragment(/cache_articles_for_main_column_\S*/)
    expire_fragment("article-for-list-#{@article.id}")
    unless @article.person.blank?
      if !@article.person.user.has_role('Author')
       @possible_authors << @article.person
      end
    end
    params[:article][:article_category_ids] ||= []
    params[:article][:article_category_ids] << @article.article_category_id unless @article.article_category_id.blank?
    if @article.update_attributes(params[:article])
      #This is to remove article from categories if there are none selected
      if !params[:article].has_key?("article_category_ids")
        @article.article_categories = []
        @article.save
      end
      ac_ids = @article.article_category_ids.uniq
      @article.article_category_ids = []
      @article.article_category_ids = ac_ids
      flash[:notice] = "Article \"#{@article.title}\" updated."
      log_activity("Updated \"#{@article.title}\"")
      session[:cache] = true
      redirect_to params[:redirect_path] ? params[:redirect_path] : admin_articles_path
    else
      render :action => "edit"
    end
  end

  def destroy
    #expire_fragment(/article\S*/)
    #expire_fragment(/cache_articles_for_main_column_\S*/)
    expire_fragment(:controller => "articles", :action => "index", :action_suffix => @article)
    @article.destroy
    respond_to :js
  end

  def preview
    if !params[:reload]
      @page = Page.find_by_permalink!('blog')
      get_page_defaults(@page)
      @menu = @page.menus.first
      @admin = false
      @hide_admin_menu = true
      
      
      @article = Article.new(JSON.parse(@settings.blog_preview))
      @images = @article.permalink.blank? ? [] : Article.find_by_permalink(@article.permalink).images
      params[:article_article_category_id].blank? ? @side_column_sections = ColumnSection.all(:conditions => {:column_id => @page.column_id, :visible => true}) : @side_column_sections = ColumnSection.all(:conditions => {:column_id => ArticleCategory.find(params[:article_article_category_id]).column_id, :visible => true})
      @owner = @article
      @article_category = @article.article_category || @article.article_categories.first
      @article.article_category.blank? ? @side_column_sections = ColumnSection.all(:conditions => {:column_id => @page.column_id, :visible => true}) : @side_column_sections = ColumnSection.all(:conditions => {:column_id => @article.article_category.column_id, :visible => true})
      add_breadcrumb @cms_config['site_settings']['blog_title'], 'blog_path'
      add_breadcrumb @article.article_category.title, @article.article_category unless @article.article_category.blank?
      add_breadcrumb '@article.title'
      
      #render 'articles/show'
    end
  end
  
  def post_preview
    @settings.update_attributes(:blog_preview => ActiveSupport::JSON.encode(params[:preview_article]))
    File.open(@cms_path, 'w') { |f| YAML.dump(@cms_config, f) }
  end
  
  def ajax_preview
    @page = Page.find_by_permalink!('blog')
    get_page_defaults(@page)
    @menu = @page.menus.first
    @admin = false
    @hide_admin_menu = true
    
    
    @article = Article.new(JSON.parse(@settings.blog_preview))
    @images = @article.permalink.blank? ? [] : Article.find_by_permalink(@article.permalink).images
    params[:article_article_category_id].blank? ? @side_column_sections = ColumnSection.all(:conditions => {:column_id => @page.column_id, :visible => true}) : @side_column_sections = ColumnSection.all(:conditions => {:column_id => ArticleCategory.find(params[:article_article_category_id]).column_id, :visible => true})
    @owner = @article
    @article_category = @article.article_category || @article.article_categories.first
    @article.article_category.blank? ? @side_column_sections = ColumnSection.all(:conditions => {:column_id => @page.column_id, :visible => true}) : @side_column_sections = ColumnSection.all(:conditions => {:column_id => @article.article_category.column_id, :visible => true})
    
    render :layout => false
  end
  
  private

  def find_article
    begin
      @article = Article.find(params[:id])
      @article.source_url.blank? ? @disabled = false : @disabled = true
    rescue
      flash[:error] = "Article not found."
      redirect_to admin_articles_path
    end
  end

  def find_article_categories_and_check_roles
    @article_categories = @article ? ArticleCategory.active.reject{|a| @article.article_category_id == a.id} : ArticleCategory.active
    @editor = true if current_user.has_role(["Admin", "Editor"])
  end

  def authorization
    authorize(@permissions['articles'], "Articles")
  end
  
  def log_activity(description)
    add_activity(controller_name.classify, @article.id, description)
  end
  
  def authorize_to_update
    authorize(@permissions['comments'], "Published Articles") if @article.published 
  end
  def assign_authors
    @possible_authors = PersonGroup.find_by_title('Author').people.reject{|p| !p.user}
    if !current_user.has_role('Author')
      @possible_authors << current_user.person
    end
    possible_authors_2 = PersonGroup.find_by_title('Admin').people.reject{|p| !p.user}
    for pa in possible_authors_2
      @possible_authors << pa
    end 
    @possible_authors = @possible_authors.uniq
  end
end



