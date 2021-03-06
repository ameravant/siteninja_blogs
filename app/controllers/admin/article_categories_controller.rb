class Admin::ArticleCategoriesController < AdminController
  unloadable # http://dev.rubyonrails.org/ticket/6001
  before_filter :authorization
  before_filter :find_article_category, :only => [ :edit, :update, :destroy ]
  # before_filter :add_crumbs
  # add_breadcrumb "Categories", "admin_article_categories_path", :except => [ :index, :destroy ]
  add_breadcrumb "New Category", nil, :only => [ :new, :create ]
  
  def index
    @article_categories = ArticleCategory.active
    add_breadcrumb "Categories", nil
  end

  def new
    @article_category = ArticleCategory.new
  end

  def create
    @article_category = ArticleCategory.new(params[:article_category])
    if @article_category.save
      add_person_groups
      flash[:notice] = "Category \"#{@article_category.name}\" created."
      log_activity("Created \"#{@article_category.name}\"")
      redirect_to admin_article_categories_path
    else
      render :action => "new"
    end
  end

  def edit
    add_breadcrumb @article_category.name
  end

  def update
    add_breadcrumb @article_category.name
    if @article_category.update_attributes(params[:article_category])
      add_person_groups
      flash[:notice] = "Category \"#{@article_category.name}\" updated."
      log_activity("Updated \"#{@article_category.name}\"")
      redirect_to admin_article_categories_path
    else
      render :action => "edit"
    end
  end

  def destroy
    log_activity("Deleted \"#{@article_category.title}\"")
    @article_category.update_attribute(:active, false)
    respond_to :js
  end

  private

  def find_article_category
    begin
      @article_category = ArticleCategory.find(params[:id])
      
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Article category was not found. It may have been deleted."
      redirect_to admin_article_categories_path
    end
  end

  def authorization
    authorize(@permissions['article_categories'], "Article Categories")
    redirect_to admin_events_path if !current_user.has_role(["Admin"])
  end

  def log_activity(description)
    add_activity(controller_name.classify, @article_category.id, description)
  end

  def add_crumbs
    add_breadcrumb @cms_config['site_settings']['blog_title'], "admin_articles_path"
  end
  
  def add_person_groups
    if @cms_config['modules']['members']
      if params[:article_category][:permission_level] == "except those checked"
        params[:article_category][:person_group_ids] = PersonGroup.is_role.collect(&:id).delete_if{|c| params[:article_category][:person_group_ids].include?(c.to_s)}
      elsif params[:article_category][:permission_level] == "administrators"
        params[:article_category][:person_group_ids] = [1]
      elsif params[:article_category][:permission_level] == "everyone"
        params[:article_category][:person_group_ids] = PersonGroup.is_role.collect(&:id)
      end        
    end
  end
  

end
