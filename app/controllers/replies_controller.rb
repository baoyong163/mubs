class RepliesController < ApplicationController
  before_filter :login_required, :only => [ :new, :create, :edit, :update, :destroy , :auto_complete_for_tag_name]
    
  auto_complete_for :tag, :name

  protect_from_forgery :except => :auto_complete_for_tag_name

  # GET /replies
  # GET /replies.xml
  def index
    if @blog
      # @replies = @blog.replies.find_new(15)
      @replies = @blog.replies.recent
    else
      @replies=Reply.find_new(15)
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @replies }
    end
  end

  # GET /replies/1
  # GET /replies/1.xml
  def show
    @article = Reply.find(params[:id])
    @blog = params[:blog_id]
    @comments = @reply.comments.paginate(:per_page => 10, :page => params[:page])
    # @comments = Comment.find(:all, :conditions => ['article_id = ?', @reply.id] ).concat( Reply.find(:all, :conditions => ['parent_id = ?', @reply.id]))
    # @comments.sort! do |x, y|
    #   x.created_at <=> y.created_at
    # end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @article }
    end
  end

  # GET /replies/new
  # GET /replies/new.xml
  def new
    @article = Reply.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @article }
    end
  end

  # GET /replies/1/edit
  def edit
    @article = Reply.find(params[:id])
  end

  # POST /replies
  # POST /replies.xml
  def create
    @article = Reply.new(params[:article])
    @reply.blog << @blog
    if params[:tag][:name] # 保存关键词
      @reply.tag_list=params[:tag][:name]
    end
    respond_to do |format|
      if @reply.save
        flash[:notice] = 'Reply was successfully created.'
        format.html { @reply.parent_id.nil? ? redirect_to([@blog, @article]) : redirect_to([@blog, Reply.find(@reply.parent_id)]) }
        format.xml  { render :xml => @article, :status => :created, :location => @article }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @reply.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /replies/1
  # PUT /replies/1.xml
  def update
    @article = Reply.find(params[:id])

    respond_to do |format|
      if @reply.update_attributes(params[:article])
        flash[:notice] = 'Reply was successfully updated.'
        if @blog
          format.html { redirect_to([@blog, @article]) } 
        else
          format.html { redirect_to(@article) } 
        end
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @reply.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /replies/1
  # DELETE /replies/1.xml
  def destroy
    @article = Reply.find(params[:id])
    @reply.destroy

    respond_to do |format|
      format.html { redirect_to(blog_replies_url(@blog)) }
      format.xml  { head :ok }
    end
  end
end
