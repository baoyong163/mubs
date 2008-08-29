class RolesController < ApplicationController

  before_filter :login_required, :only => [ :new, :create, :edit, :update, :destroy , :auto_complete_for_tag_name]

  in_place_edit_for :role, :title
  in_place_edit_for :role, :digest
  in_place_edit_for :role, :body

  # GET /roles
  # GET /roles.xml
  def index
    @users=User.find(:all, :limit => 15)
    @roles=Role.find(:all)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @roles }
    end
  end

  # GET /roles/1
  # GET /roles/1.xml
  def show
    @role  = Role.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @role }
    end
  end

  # GET /roles/new
  # GET /roles/new.xml
  def new
    @role = Role.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @role }
    end
  end

  # GET /roles/1/edit
  def edit
    @role = Role.find(params[:id])
  end

  # POST /roles
  # POST /roles.xml
  def create
    @role = Role.new(params[:role])
    respond_to do |format|
      if @role.save
        flash[:notice] = 'Role was successfully created.'
        format.html { redirect_to(@role) }
        format.xml  { render :xml => @role, :status => :created, :location => @role }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /roles/1
  # PUT /roles/1.xml
  def update
    @role = Role.find(params[:id])
    @role.blogs + [@blog] if @blog # @blog不为数组时，以后考虑多个blog的情况
    @role.users << current_user
    if params[:tag][:name] # 保存关键词
      @role.tag_list=params[:tag][:name]
    end
    respond_to do |format|
      if @role.update_attributes(params[:role])
        flash[:notice] = 'Role was successfully updated.'
        if @blog
          format.html { redirect_to([@blog, @role]) } 
        else
          format.html { redirect_to(@role) } 
        end
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /roles/1
  # DELETE /roles/1.xml
  def destroy
    @role = Role.find(params[:id])
    @role.destroy

    respond_to do |format|
      format.html { redirect_to(blog_roles_url(@blog)) }
      format.xml  { head :ok }
    end
  end

end
