class BlogsController < ApplicationController
  
  before_filter :login_required, :only => [:new, :create, :update, :destroy]
  # before_filter :account_required, :only => :show
  # before_filter :sub_site
  before_filter :find_subdomain

  # mubs的总首页
  def home
    if @user
      @blogs = @user.blogs
      @articles = @user.articles.paginate(:per_page => 10, :page => params[:page],:conditions => {:is_reply => false},:order => "created_at DESC")
      @tags = @user.articles.tag_counts
    elsif @blog
      @articles = @blog.articles.paginate(:per_page => 10, :page => params[:page], :order => "created_at DESC")
      @tags = @blog.articles.tag_counts
    else
      @blogs = Blog.find(:all)
    end
    respond_to do |format|
      if @user
        format.html { render :file => 'users/show', :layout => true, :use_full_path => true }
      elsif @blog
        format.html { render :action => :show}
      else
        format.html # home.html.erb
      end
      format.xml  { render :xml => @blogs }
    end
  end
  
  # GET /blogs
  # GET /blogs.xml
  def index
    @blogs = Blog.paginate(:per_page => 10, :page => params[:page], :order => "created_at DESC")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @blogs }
    end
  end
  
  # GET /blogs/1
  # GET /blogs/1.xml
  def show
    if params[:id]
      @blog = Blog.find(params[:id]) 
    end
    @articles = @blog.articles.paginate(:per_page => 10, :page => params[:page], :order => "created_at DESC")
    @tags = @blog.articles.tag_counts
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @blog }
    end
  end

  # GET /blogs/new
  # GET /blogs/new.xml
  def new
    @blog = Blog.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @blog }
    end
  end

  # GET /blogs/1/edit
  def edit
    @blog = Blog.find(params[:id])
  end

  # POST /blogs
  # POST /blogs.xml
  def create
    @blog = Blog.new(params[:blog])
    @blog.users << current_user
    respond_to do |format|
      if @blog.save
        flash[:notice] = 'Blog was successfully created.'
        format.html { redirect_to(@blog) }
        format.xml  { render :xml => @blog, :status => :created, :location => @blog }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @blog.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /blogs/1
  # PUT /blogs/1.xml
  def update
    @blog = Blog.find(params[:id])

    respond_to do |format|
      if @blog.update_attributes(params[:blog])
        flash[:notice] = 'Blog was successfully updated.'
        format.html { redirect_to(@blog) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @blog.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /blogs/1
  # DELETE /blogs/1.xml
  def destroy
    @blog = Blog.find(params[:id])
    @blog.destroy

    respond_to do |format|
      format.html { redirect_to(blogs_url) }
      format.xml  { head :ok }
    end
  end
  
protected

  # def sub_site
  #   if current_subdomain
  #     if @user = User.find_by_subdomain(current_subdomain)
  #       redirect_to user_path(@user)
  #     else
  #       redirect_to root_path(:subdomain => false)  
  #       # render :url_for  => {:controller => 'blogs', :action => 'home', :subdomain => false}
  #     end
  #   else
  #     # redirect_to '/'
  #     render :action => 'home'
  #   end
  # end
  
  def unkown_request
    # redirect_to "/404.html"
    render_404
  end
  
end
