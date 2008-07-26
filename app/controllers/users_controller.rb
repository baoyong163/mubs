class UsersController < ApplicationController
  
  # Protect these actions behind an admin login
  before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :find_user, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :login_required, :only => [:index, :edit, :update, :change_password]
  
  auto_complete_for :user, :login
  auto_complete_for :user, :subdomain

  protect_from_forgery :except => :auto_complete_for_user_login

  
  def index
    @users=User.paginate(:per_page => 10, :page => params[:page], :order => "created_at DESC")
  end
  
  def show
    @user=User.find(params[:id]) unless @user
    @articles = @user.articles.paginate(:per_page => 10, :page => params[:page], :conditions => {:is_reply => false},:order => "created_at DESC")
    @tags = @user.articles.tag_counts
    respond_to do |format|
      format.html do
        response.headers['X-XRDS-Location'] = formatted_identity_url(:user => @user, :format => :xrds, :protocol => scheme)
      end
      format.xrds
    end
  end

  def new
    @user = User.new
  end

=begin
Use attribute_fu plugin to create sub-model
@user.open_id_attributes = params[:open_id_attributes]

  Parameters: {
    "user"=>{
      "name"=>"jayesoui", 
      "password_confirmation"=>"",
      "open_id_attributes"=>{
        "new"=>{
          "0"=>{"url"=>"http://测试.myopenid.com/ "},
          "1"=>{"url"=>"http://test.myopenid.com/"}, 
          "2"=>{"url"=>""}
        }
      }, 
      "login"=>"jayesoui", 
      "password"=>"", 
      "email"=>"test@test.com"
    },
    "commit"=>"Update", 
    "authenticity_token"=>"cf33167a49d72312a9789c3e8ecd5c2493b6ce0f", 
    "_method"=>"put", 
    "action"=>"update", 
    "id"=>"3", 
    "controller"=>"users"
  }
=end
  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    @user.open_id_attributes = params[:open_id_attributes] # use attribute_fu plugin to create sub-model
    @user.subdomain = Idna.toASCII(params[:user][:login])
    @user.register! if @user && @user.valid?
    success = @user && @user.valid?
    if success && @user.errors.empty?
            redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      render :action => 'new'
    end
  end
  
  def edit
    @user=User.find(params[:id])
    @open_ids = @user.open_ids
  end
  
=begin
Use attribute_fu plugin to update sub-model
@user.open_id_attributes = params[:open_id_attributes]

  Parameters: {
    "user"=>{
      "name"=>"jayesoui", 
      "password_confirmation"=>"",
      "open_id_attributes"=>{
        "new"=>{
          "0"=>{"url"=>"http://测试.myopenid.com/ "},
          "1"=>{"url"=>"http://test.com/"}, 
          "2"=>{"url"=>""}
        }
      }, 
      "login"=>"jayesoui", 
      "password"=>"", 
      "email"=>"test@test.com"
    },
    "commit"=>"Update", 
    "authenticity_token"=>"cf33167a49d72312a9789c3e8ecd5c2493b6ce0f", 
    "_method"=>"put", 
    "action"=>"update", 
    "id"=>"3", 
    "controller"=>"users"
  }
=end
  def update
    @user = User.find(params[:id])
    @user.open_id_attributes = params[:open_id_attributes] # use attribute_fu plugin to update sub-model
    @user.subdomain = Idna.toASCII(params[:user][:login])
    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = "Signup complete! Please sign in to continue."
      redirect_to '/login'
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default('/')
    else 
      flash[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default('/')
    end
  end

  def suspend
    @user.suspend! 
    redirect_to users_path
  end

  def unsuspend
    @user.unsuspend! 
    redirect_to users_path
  end

  def destroy
    @user.delete!
    redirect_to users_path
  end

  def purge
    @user.destroy
    redirect_to users_path
  end
  
  def change_password
    if User.authenticate(current_user.login, params[:old_password])
      if ((params[:password] == params[:password_confirmation]) && !params[:password_confirmation].blank?)
        current_user.password_confirmation = params[:password_confirmation]
        current_user.password = params[:password]        
        if current_user.save
          flash[:notice] = 'Your password has been changed.'
          redirect_to edit_user_path(:user => current_user)
        else
          flash[:error] = 'Sorry, your password could not be changed.'
          redirect_to edit_user_path
        end
      else
        flash[:error] = 'The confirmation of the new password was incorrect.'
        @old_password = params[:old_password]
        redirect_to edit_user_path
      end
    else
      flash[:error] = 'Your old password is incorrect.'
      redirect_to edit_user_path
    end 
  end

protected
  def find_user
    @user = User.find(params[:id])
  end

end
