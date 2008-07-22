class PasswordsController < ApplicationController

  before_filter :find_user_by_reset_code, :only => [:edit, :update]

  # Forgot password
  def create
    if @user = User.find_by_email(params[:email], :conditions => 'activation_code IS NULL')
      @user.forgot_password!   
      flash[:notice] = 'A password reset link has been sent to your email address.'
      redirect_to login_path
    else
      flash[:error] = 'Could not find a user with that email address.'
      render :action => 'new'
    end
  end
  
  # Reset password
  def update
    unless params[:password].blank?
      if @user.update_attributes(:password => params[:password], :password_confirmation => params[:password_confirmation])
        @user.reset_password
        flash[:notice] = 'Password reset.'
        redirect_to login_path
      else
        flash[:error] = 'Password mismatch.'
        render :action => 'edit'
      end
    else
      flash[:error] = 'Password cannot be blank.'
      render :action => 'edit'
    end
  end
  
  private
  
  def find_user_by_reset_code
    @reset_code = params[:id]
    @user = User.find_by_password_reset_code(@reset_code) unless @reset_code.blank?
    unless @user
      flash[:error]  = 'Sorry, your password reset code is invalid. Please check the code and try again.'
      redirect_to new_password_path
    end
  end
  
end