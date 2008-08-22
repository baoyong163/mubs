require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PasswordsController do
  fixtures :users
  
  # before(:each) do
  #   @user = mock_model(User)
  #   User.stub!(:find).and_return([@user])
  # end
  
  it "should get new" do
    get :new
    response.should be_success
  end

  it "should dispaly error when email could not be found" do
    post :create, :email => 'doesnotexist@somewhere.com'
    flash.now[:error].should_not be_nil
    response.should render_template('new')
  end

  it "should reset password when email could be found" do
    @user = users(:quentin)
    post :create, :email => @user.email
    @user.reload.password_reset_code.should_not be_nil
    flash.now[:notice].should_not be_nil
    response.should redirect_to(login_url)
  end

  it "should redirect to new if code is missing" do
    get :edit
    flash.now[:error].should_not be_nil
    response.should redirect_to(new_password_url)
  end

  it "should should redirect to new if code is invalid" do
    get :edit, :id => 'doesnotexist'
    flash.now[:error].should_not be_nil
    response.should redirect_to(new_password_url)   
  end
  
  it "should reset the password when it matches confirmation" do
    @user = users(:quentin)
    old_crypted_password = @user.crypted_password
    @user.forgot_password!
    put :update, 
        :id                    => @user.password_reset_code,
        :password              => 'v4l1d_n3w_pa$$w0rD',
        :password_confirmation => 'v4l1d_n3w_pa$$w0rD'
    old_crypted_password.should_not equal @user.reload.crypted_password
    flash.now[:notice].should_not be_nil
    response.should redirect_to(login_url)
  end
  
  it "should not rest the password if it is blank" do
    @user = users(:quentin)
    old_crypted_password = @user.crypted_password
    @user.forgot_password!
    new_password = ''
    put :update, 
        :id                    => @user.password_reset_code,
        :password              => new_password,
        :password_confirmation => new_password
    old_crypted_password.should equal @user.reload.crypted_password
    flash.now[:error].should_not be_nil
    response.should render_template('edit')
  end
  
  it "should not reset the password if it does not match confirmation" do
    @user = users(:quentin)
    old_crypted_password = @user.crypted_password
    @user.forgot_password!
    put :update, 
        :id                    => @user.password_reset_code,
        :password              => 'v4l1d_n3w_pa$$w0rD',
        :password_confirmation => 'other_password'
    old_crypted_password.should equal @user.reload.crypted_password
    flash.now[:error].should_not be_nil
    response.should render_template('edit')
  end
  
end
