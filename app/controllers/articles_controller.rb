class ArticlesController < ApplicationController
  
  before_filter :load_blog, :login_required, :only => [ :new, :create, :edit, :update, :destroy , :auto_complete_for_tag_name]
  
  in_place_edit_for :article, :title
  in_place_edit_for :article, :digest
  in_place_edit_for :article, :body
  auto_complete_for :tag, :name

  protect_from_forgery :except => :auto_complete_for_tag_name

  # GET /articles
  # GET /articles.xml
  def index
    if @blog
      # @articles = @blog.articles.find_new(15)
      # @articles = @blog.articles.recent
      @articles = @blog.articles.paginate(:per_page => 10, :page => params[:page], :order => "created_at DESC")
    else
      # @articles=Article.find_new(15)
      @articles=Article.paginate(:per_page => 10, :page => params[:page], :order => "created_at DESC")
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @articles }
    end
  end

  # GET /articles/1
  # GET /articles/1.xml
  def show
    @article = Article.find(params[:id])
    @blog = params[:blog_id]
    @comments = @article.comments.paginate(:per_page => 10, :page => params[:page])
    @replies = @article.replies.paginate(:per_page => 10, :page => params[:page])
    @article.view!
    # @comments = Comment.find(:all, :conditions => ['article_id = ?', @article.id] ).concat( Article.find(:all, :conditions => ['parent_id = ?', @article.id]))
    @comments = @replies + Comment.find(:all)#paginate(:per_page => 10, :page => params[:page])
    @comments.sort! do |x, y|
      x.created_at <=> y.created_at
    end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @article }
    end
  end

  # GET /articles/new
  # GET /articles/new.xml
  def new
    @article = Article.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @article }
    end
  end

  # GET /articles/1/edit
  def edit
    @article = Article.find(params[:id])
  end

  # POST /articles
  # POST /articles.xml
  def create
    @article = Article.new(params[:article])
    @article.blog << @blog
    if params[:tag][:name] # 保存关键词
      @article.tag_list=params[:tag][:name]
    end
    respond_to do |format|
      if @article.save
        flash[:notice] = 'Article was successfully created.'
        format.html { @article.parent_id.nil? ? redirect_to([@blog, @article]) : redirect_to([@blog, Article.find(@article.parent_id)]) }
        format.xml  { render :xml => @article, :status => :created, :location => @article }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @article.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /articles/1
  # PUT /articles/1.xml
  def update
    @article = Article.find(params[:id])
    @article.blog + [@blog] if @blog # @blog不为数组时，以后考虑多个blog的情况
    if params[:tag][:name] # 保存关键词
      @article.tag_list=params[:tag][:name]
    end
    respond_to do |format|
      if @article.update_attributes(params[:article])
        flash[:notice] = 'Article was successfully updated.'
        if @blog
          format.html { redirect_to([@blog, @article]) } 
        else
          format.html { redirect_to(@article) } 
        end
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @article.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /articles/1
  # DELETE /articles/1.xml
  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    respond_to do |format|
      format.html { redirect_to(blog_articles_url(@blog)) }
      format.xml  { head :ok }
    end
  end
  
private
   def load_blog 
     @blog = Blog.find(params[:blog_id]) if params[:blog_id]
   end 
end
