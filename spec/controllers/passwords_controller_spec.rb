require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PasswordsController do

  #Delete this example and add some real ones
  it "should use PasswordsController" do
    controller.should be_an_instance_of(PasswordsController)
  end
  
  it "should get new" do
    get :new
    response.should be_success
  end

  it "should dispaly error when email could not be found" do
        post :create, :email => 'doesnotexist@somewhere.com'
    assert @response.has_flash_object?(:error)
    assert_template 'new'
  end

  it "should reset password when email could be found" do
        @account = accounts(:standard)
    post :create, :email => @account.email
    assert_not_nil @account.reload.password_reset_code
    assert @response.has_flash_object?(:notice)
    assert_redirected_to login_url
  end

  it "should redirect to new if code is missing" do
        get :edit
    assert @response.has_flash_object?(:error)
    assert_redirected_to new_password_url
  end
  
  it "should should redirect to new if code is invalid" do
    get :edit, :id => 'doesnotexist'
    assert @response.has_flash_object?(:error)
    assert_redirected_to new_password_url    
  end
  
  it "should reset the password when it matches confirmation" do
    @account = accounts(:standard)
    old_crypted_password = @account.crypted_password
    @account.forgot_password!
    put :update, :id => @account.password_reset_code,
      :password => 'v4l1d_n3w_pa$$w0rD',
      :password_confirmation => 'v4l1d_n3w_pa$$w0rD'
    assert_not_equal old_crypted_password, @account.reload.crypted_password
    assert @response.has_flash_object?(:notice)
    assert_redirected_to login_url
  end
  
  it "should not rest the password if it is blank" do
    @account = accounts(:standard)
    old_crypted_password = @account.crypted_password
    @account.forgot_password!
    new_password = ''
    put :update, :id => @account.password_reset_code,
      :password => new_password,
      :password_confirmation => new_password
    assert_equal old_crypted_password, @account.reload.crypted_password
    assert @response.has_flash_object?(:error)
    assert_template 'edit'
  end
  
  it "should not reset the password if it does not match confirmation" do
    @account = accounts(:standard)
    old_crypted_password = @account.crypted_password
    @account.forgot_password!
    put :update, :id => @account.password_reset_code,
      :password => 'v4l1d_n3w_pa$$w0rD',
      :password_confirmation => 'other_password'
    assert_equal old_crypted_password, @account.reload.crypted_password
    assert @response.has_flash_object?(:error)
    assert_template 'edit'
  end
  
end
