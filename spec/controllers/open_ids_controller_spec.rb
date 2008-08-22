require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OpenIdsController do

  fixtures :users

  it "should save site if user chose to trust always" do
    fake_checkid_request(:quentin)
    assert_difference('Site.count', 1) do
      post :complete, :always => 1,
        :site => {
          :persona_id => personas(:public).id,
          :url => checkid_request_params['openid.trust_root'],
          :properties => valid_properties }
    end
    assert_response :redirect
    assert @response.redirect_url_match?(checkid_request_params['openid.return_to'])
    assert @response.redirect_url_match?(/mode=id_res/)
  end
  
  it "should not save site if user chose to trust temporary" do
    fake_checkid_request(:quentin)
    assert_no_difference('Site.count') do
      post :complete, :temporary => 1,
        :site => valid_site_attributes.merge(:properties => valid_properties)
    end
    assert_response :redirect
    assert @response.redirect_url_match?(checkid_request_params['openid.return_to'])
    assert @response.redirect_url_match?(/mode=id_res/)
  end
  
  it "should redirect to openid cancel url if user chose to cancel" do
    fake_checkid_request(:quentin)
    post :complete, :cancel => 1
    assert_response :redirect
    assert @response.redirect_url_match?(checkid_request_params['openid.return_to'])
    assert @response.redirect_url_match?(/mode=cancel/)
  end
  
  it "should ask user to login if claimed id does not belong to current user" do
    login_as(:quentin)
    id_url = "http://notmine.com"
    post :index, checkid_request_params.merge('openid.identity' => id_url, 'openid.claimed_id' => id_url)
    assert_redirected_to safe_login_url
    assert_not_nil @request.session[:return_to]
    assert_not_nil @request.session[:request_token]
  end
  
  it "should clear old request when recieving a new one" do
    fake_checkid_request(:quentin)
    token_for_first_request = @request.session[:request_token]
    assert token_for_first_request
    post :index
    assert_not_equal @request.session[:request_token], token_for_first_request
    request.session[:request_token].should_not equal token_for_first_request
    assert_nil OpenIdRequest.find_by_token(token_for_first_request)
  end
  
  it "should directly answer incoming associate requests" do
    post :index, associate_request_params
    assert_response :success
    assert_match 'assoc_handle', @response.body
    assert_match 'assoc_type', @response.body
    assert_match 'session_type', @response.body
    assert_match 'expires_in', @response.body
  end
  
  it "should require login for proceed" do
    get :proceed
    assert_login_required
  end
  
  it "should require login for decide" do
    get :decide
    assert_login_required
  end

  it "should require login for complete" do
    get :complete
    assert_login_required
  end
  
  private
  
  # Takes the name of an user fixture for which to fake the request
  def fake_checkid_request(user)
    login_as(user)
    id_url = identifier(users(user))
    openid_params = checkid_request_params.merge('openid.identity' => id_url, 'openid.claimed_id' => id_url)
    @checkid_request = OpenIdRequest.create(:parameters => openid_params)
    @request.session[:request_token] = @checkid_request.token
  end
  
  def identifier(user)
    "http://test.host/#{user.login}"
  end
  
end
