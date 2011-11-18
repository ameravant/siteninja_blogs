class Admin::ArticlesController < AdminController
  unloadable # http://dev.rubyonrails.org/ticket/6001
  before_filter :authorization
  before_filter :assign_authors, :only => [:edit, :new, :create, :update]
  before_filter :find_article, :only => [ :edit, :update, :destroy, :reorder, :show ]
  before_filter :find_article_categories_and_check_roles, :only => [ :new, :create, :edit, :update ]
  before_filter :authorize_to_update, :only => [:edit, :update, :destroy]
  def index
    add_breadcrumb @cms_config['site_settings']['blog_title']
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
    if !@article.person.user.has_role('Author') and current_user != @article.user
      @possible_authors << @article.person      
    end
    if !current_user.has_role('Author')
      @possible_authors << current_user.person
    end
  end

  def create
    # The following line allows an Editor or Administrator to save an article as a different person
    @editor ? (@article = Article.new(params[:article])) : (@article = current_user.person.articles.build(params[:article]))
    @article.published = false unless current_user.has_role(["Admin", "Editor", "Author"])
    @article.published_at = Time.now if @article.publish_immediately = true
    #this makes sure the main article category is also in the habtm relationship so it will scope correctly
    params[:article][:article_category_ids] ||= []
    params[:article][:article_category_ids] = params[:article][:article_category_ids] << @article.article_category_id unless @article.article_category_id.blank?
    if @article.save
      flash[:notice] = "Article \"#{@article.title}\" created."
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
    if !@article.person.user.has_role('Author')
     @possible_authors << @article.person
    end
    params[:article][:article_category_ids] ||= []
    params[:article][:article_category_ids] = params[:article][:article_category_ids] << @article.article_category_id unless @article.article_category_id.blank?
    if @article.update_attributes(params[:article])
      #This is to remove product from categories if there are none selected
      if !params[:article].has_key?("article_category_ids")
        @article.article_categories = []
        @article.save
      end
      flash[:notice] = "Article \"#{@article.title}\" updated."
      redirect_to admin_articles_path
    else
      render :action => "edit"
    end
  end

  def destroy
    @article.destroy
    respond_to :js
  end

  def preview
    @page = Page.find_by_permalink!('blog')
    @menu = @page.menus.first
    @admin = false
    @menus = Menu.all
    @settings = Setting.first
    @footer_menus = Menu.find(:all, :conditions => {:show_in_footer => true}, :order => :footer_pos )
    @hide_admin_menu = true
    params[:article_id].blank? ? @article = Article.new : @article = Article.find(params[:article_id])
    @images = @article.images
    params[:article_article_category_id].blank? ? @side_column_sections = ColumnSection.all(:conditions => {:column_id => @page.column_id, :visible => true}) : @side_column_sections = ColumnSection.all(:conditions => {:column_id => ArticleCategory.find(params[:article_article_category_id]).column_id, :visible => true})
    @owner = @article
    #@article.body = params[:article_body]
    @article.person = Person.find(params[:article_person_id])
    @article.title = params[:article_title]
    @article.description = params[:article_description]
    @article.blurb = params[:article_blurb]
    @article.published_at = Time.now if params[:article_id].blank?
  end
  
  def post_preview
    @cms_config['site_settings']['preview'] = params[:post_preview][:body]
    File.open("#{RAILS_ROOT}/config/cms.yml", 'w') { |f| YAML.dump(@cms_config, f) }
  end
  
  private

  def find_article
    begin
      @article = Article.find(params[:id])
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
  def authorize_to_update
    authorize(@permissions['comments'], "Published Articles") if @article.published 
  end
  def assign_authors
    @possible_authors = PersonGroup.find_by_title('Author').people.reject{|p| !p.user}
    if !current_user.has_role('Author')
      @possible_authors << current_user.person
    end
  end
end

