class Admin::CommentsController < AdminController
  unloadable # http://dev.rubyonrails.org/ticket/6001
  before_filter :authorization
  before_filter :find_article
  before_filter :find_comment, :only => [ :edit, :update, :destroy ]
  before_filter :add_article_crumb

  def index
    add_breadcrumb "Comments"
    if params[:q].blank?
      @all_comments = @article.comments
    else
      q = params[:q].strip
      @all_comments = @article.comments.find(:all, :conditions => ["name like ? or email like ?", "%#{q}%", "%#{q}%"])
    end
    @comments = @all_comments.paginate(:page => params[:page], :per_page => 50)
  end

  def new
    add_breadcrumb "Comments", "admin_article_comments_path(@article)"
    @comment = @article.comments.build
    @comment.email = current_user.email
    add_breadcrumb "New"
  end

  def create
     @comment = @article.comments.build(params[:comment])
     @comment.user = current_user
    if @comment.save
      flash[:notice] = "Your comment has been added."
      redirect_to admin_article_comments_path(@article)
    else
      render :action => "new"
    end
  end

  def edit
    add_breadcrumb "Edit"
  end

  def update
    if @comment.update_attributes(params[:comment])
      flash[:notice] = "Comment posted by \"#{@comment.name}\" updated."
      redirect_to admin_article_comments_path(@article)
    else
      render :action => "edit"
    end
  end

  def destroy
     @comment.destroy
    respond_to :js
  end


  private

  def find_article
    begin
      @article = Article.find(params[:article_id])
    rescue
      flash[:error] = "Article not found."
      redirect_to admin_articles_path
    end
  end

  def find_comment
    begin
      @comment = @article.comments.find(params[:id])
    rescue
      redirect_to [:admin, article, :comments]
    end
  end

  def add_article_crumb
    add_breadcrumb @cms_config['site_settings']['blog_title'], admin_articles_path
    add_breadcrumb @article.title, edit_admin_article_path(@article)
  end

  def authorization
    authorize(@permissions['comments'], "Comments")
  end
end

