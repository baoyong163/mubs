class RepliesController < ApplicationController
  before_filter :login_required, :only => [ :new, :create, :edit, :update, :destroy , :auto_complete_for_tag_name]
    
  in_place_edit_for :reply , :title
  in_place_edit_for :reply , :digest
  in_place_edit_for :reply , :body
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
    @reply = Reply.find(params[:id])
    @article  = Article.find(params[:article_id])
    # @blog = params[:blog_id]
    # @comments = @reply.comments.paginate(:per_page => 10, :page => params[:page])
    # @comments = Comment.find(:all, :conditions => ['article_id = ?', @reply.id] ).concat( Reply.find(:all, :conditions => ['parent_id = ?', @reply.id]))
    # @comments.sort! do |x, y|
    #   x.created_at <=> y.created_at
    # end
    respond_to do |format|
      format.html
      format.xml  { render :xml => @reply }
    end
  end

  # GET /replies/new
  # GET /replies/new.xml
  def new
    @reply = Reply.new(:parent_id => params[:article_id],:attitude => params[:attitude])
    @article  = Article.find(params[:article_id])
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @reply }
    end
  end

  # GET /replies/1/edit
  def edit
    @reply = Reply.find(params[:id])
  end

  # POST /replies
  # POST /replies.xml
  def create
    @article          = Article.find(params[:article_id]) # 取得被回复帖子
    @reply            = Reply.new(params[:reply])
    @reply.is_reply   = true
    @reply.parent_id  = params[:article_id]
    @reply.thread_id  = @article.thread_id # 回复和被回复贴有同样的thread_id
    @reply.author     = current_user.login
    @blog             = @article.blog
    # @reply.blog << @blog
    if params[:tag][:name] # 保存关键词
      @reply.tag_list = params[:tag][:name]
    end
    result            = @reply.save
    # pages = @article.replies.paginate(:per_page => 15, :page => 1).total_pages
    # @replies = @article.replies.paginate(:per_page => 15, :page => pages)
    @article.reply_count!
    respond_to do |format|
      # if @reply.save
      #   flash[:notice] = 'Reply was successfully created.'
      #   format.html { @reply.parent_id.nil? ? redirect_to([@article, @reply ]) : redirect_to([@blog, Reply.find(@reply.parent_id)]) }
      #   format.xml  { render :xml => @reply , :status => :created, :location => @reply }
      # else
      #   format.html { render :action => "new" }
      #   format.xml  { render :xml => @reply.errors, :status => :unprocessable_entity }
      # end
      if result
        flash[:notice] = '回复成功保存'
        # format.html { redirect_to([@article, @reply ]) }
        format.html { redirect_to article_path(@article) }
        # { redirect_to article_reply_path(@reply.parent_id, @reply.id) }
        format.js do 
          render :update do |page|
            page.replace_html "main", :file => "articles/show"
          end
        end
        format.xml do
          headers["Location"] = article_reply_path(@reply.parent_id, @reply.id)
          render :nothing => true, :status => "201 Created"
        end
      else
        format.html { render :action => "new" }
        format.js do
          render :update do |page|
            page.replace_html "main", :partial => "new"
          end
        end
        format.xml  { render :xml => @reply.errors.to_xml }
      end
    end
  end

  # PUT /replies/1
  # PUT /replies/1.xml
  def update
    @reply = Reply.find(params[:id])

    respond_to do |format|
      if @reply.update_attributes(params[:reply ])
        flash[:notice] = 'Reply was successfully updated.'
        if @blog
          format.html { redirect_to([@blog, @reply ]) } 
        else
          format.html { redirect_to(@reply ) } 
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
    @reply = Reply.find(params[:id])
    @reply.destroy

    respond_to do |format|
      format.html { redirect_to(blog_replies_url(@blog)) }
      format.xml  { head :ok }
    end
  end
end
