class Admin::ArticlesController < AdminController
  unloadable # http://dev.rubyonrails.org/ticket/6001
  before_filter :authorization
  before_filter :find_article, :only => [ :edit, :update, :destroy, :reorder, :show ]
  before_filter :find_article_categories_and_check_roles, :only => [ :new, :create, :edit, :update ]

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
  end

  def edit
    add_breadcrumb @cms_config['site_settings']['blog_title'], admin_articles_path
    add_breadcrumb "Edit"
  end

  def create
    # The following line allows an Editor or Administrator to save an article as a different person
    @editor ? (@article = Article.new(params[:article])) : (@article = current_user.person.articles.build(params[:article]))
    @article.published = false unless current_user.has_role(["Admin", "Editor", "Author"])
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
    if @article.update_attributes(params[:article])
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
    @article_categories = ArticleCategory.active
    @editor = true if current_user.has_role(["Admin", "Editor"])
  end

  def authorization
    authorize(@permissions['articles'], "Articles")
  end

end

