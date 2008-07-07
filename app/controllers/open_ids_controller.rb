require 'pathname'
require "openid"
require "openid/consumer/discovery"
require 'openid/extensions/sreg'
require 'openid/extensions/pape'
require 'openid/store/filesystem'

include ViewsHelper

class OpenIdsController < ApplicationController


  include OpenID::Server

  before_filter :login_required, :only => [ :new, :create, :edit, :update, :destroy]

  protect_from_forgery :except => [:index, :create, :decision]

  # GET /open_ids
  # GET /open_ids.xml
  def index
    # @open_ids = OpenId.find(:all)
    
    # 将查询参数转换为OpenIDRequest对象，如果不是OpenID请求，返回nil
    # Transform query parameters into an OpenIDRequest.
    # If the query does not seem to be an OpenID request at all, return nil.
    begin
      oidreq = server.decode_request(params)
    rescue ProtocolError => e
      # invalid openid request, so just display a page with an error message
      render :text => e.to_s, :status => 500
      return
    end
    
    # no openid.mode was given
    unless oidreq
      render :text => "This is an OpenID server endpoint."
      return
    end
    
    oidresp = nil
    
    # A request to confirm the identity of a user.
    # This class handles requests for openid modes checkid_immediate and checkid_setup .
    if oidreq.kind_of?(CheckIDRequest)
      identity = oidreq.identity
      
      # Is the identifier to be selected by the IDP?、
      if oidreq.id_select
        if oidreq.immediate
          oidresp = oidreq.answer(false)
        elsif session[:user_id].nil?
          # The user hasn't logged in.
          show_decision_page(oidreq)
          return
        else
          # Else, set the identity to the one the user is using.
          identity = url_for_user
        end
      end
      
      if oidresp
        nil
      elsif self.is_authorized(identity, oidreq.trust_root)
        oidresp = oidreq.answer(true, nil, identity)
        # add the sreg response if requested
        add_sreg(oidreq, oidresp)
        # ditto pape
        add_pape(oidreq, oidresp)
      elsif oidreq.immediate
        server_url = url_for :action => 'index'
        oidresp = oidreq.answer(false, server_url)
      else
        show_decision_page(oidreq)
        return
      end
      
    else
      oidresp = server.handle_request(oidreq)
    end
    self.render_response(oidresp)
    # respond_to do |format|
    #   format.html # index.html.erb
    #   format.xml  { render :xml => @open_ids }
    # end
  end

  def show_decision_page(oidreq, message="Do you trust this site with your identity?")
    session[:last_oidreq] = oidreq
    @oidreq = oidreq
    if message
      flash[:notice] = message
    end
    render :template => 'open_ids/decide'#, :layout => 'server'
  end

  def user_page
    @user=User.find_by_login(params[:username])# unless @user
    # Yadis content-negotiation: we want to return the xrds if asked for.
    accept = request.env['HTTP_ACCEPT']
    # This is not technically correct, and should eventually be updated
    # to do real Accept header parsing and logic.  Though I expect it will work
    # 99% of the time.
    if accept and accept.include?('application/xrds+xml')
      user_xrds
      return
    end
    # content negotiation failed, so just render the user page
    xrds_url = url_for(:controller=>'user',:action=>params[:username])+'/xrds'
    href = url_for(:action => 'index')
    # Also add the Yadis location header, so that they don't have
    # to parse the html unless absolutely necessary.
    response.headers['X-XRDS-Location'] = xrds_url
    # render :text => identity_page
    render :template => 'users/show'
  end

  def user_xrds
    types = [OpenID::OPENID_2_0_TYPE,OpenID::OPENID_1_0_TYPE,OpenID::SREG_URI]
    render_xrds(types)
  end

  def idp_xrds
    types = [OpenID::OPENID_IDP_2_0_TYPE]
    render_xrds(types)
  end

  def decision
    oidreq = session[:last_oidreq]
    session[:last_oidreq] = nil
    if params[:yes].nil?
      redirect_to oidreq.cancel_url
      return
    else
      id_to_send = params[:id_to_send]
      identity = oidreq.identity
      if oidreq.id_select
        if id_to_send and id_to_send != ""
          session[:username] = id_to_send
          session[:approvals] = []
          identity = url_for_user
        else
          msg = "You must enter a username to in order to send " +
          "an identifier to the Relying Party."
          show_decision_page(oidreq, msg)
          return
        end
      end
      if session[:approvals]
        session[:approvals] << oidreq.trust_root
      else
        session[:approvals] = [oidreq.trust_root]
      end
      oidresp = oidreq.answer(true, nil, identity)
      add_sreg(oidreq, oidresp)
      add_pape(oidreq, oidresp)
      return self.render_response(oidresp)
    end
  end

  # GET /open_ids/1
  # GET /open_ids/1.xml
  def show
    @open_id = OpenId.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @open_id }
    end
  end

  # GET /open_ids/new
  # GET /open_ids/new.xml
  def new
    @open_id = OpenId.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @open_id }
    end
  end

  # GET /open_ids/1/edit
  def edit
    @open_id = OpenId.find(params[:id])
  end

  # POST /open_ids
  # POST /open_ids.xml
  def create
    @open_id = OpenId.new(params[:open_id])

    respond_to do |format|
      if @open_id.save
        flash[:notice] = 'OpenId was successfully created.'
        format.html { redirect_to(@open_id) }
        format.xml  { render :xml => @open_id, :status => :created, :location => @open_id }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @open_id.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /open_ids/1
  # PUT /open_ids/1.xml
  def update
    @open_id = OpenId.find(params[:id])

    respond_to do |format|
      if @open_id.update_attributes(params[:open_id])
        flash[:notice] = 'OpenId was successfully updated.'
        format.html { redirect_to(@open_id) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @open_id.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /open_ids/1
  # DELETE /open_ids/1.xml
  def destroy
    @open_id = OpenId.find(params[:id])
    @open_id.destroy

    respond_to do |format|
      format.html { redirect_to(open_ids_url) }
      format.xml  { head :ok }
    end
  end

  protected
  def server
    if @server.nil?
      server_url = url_for :action => 'index', :only_path => false
      # dir = Pathname.new(RAILS_ROOT).join('db').join('openid-store')
      # store = OpenID::Store::Filesystem.new(dir)
      store = ActiveRecordStore.new
      # store = OpenIdAuthentication::DbStore.new
      @server = Server.new(store, server_url)
    end
    return @server
  end

  def approved(trust_root)
    return false if session[:approvals].nil?
    return session[:approvals].member?(trust_root)
  end

  def is_authorized(identity_url, trust_root)
    return (session[:username] and (identity_url == url_for_user) and self.approved(trust_root))
  end

  def render_xrds(types)
    type_str = ""
    types.each { |uri| type_str << "<Type>#{uri}</Type>\n      "}
    yadis = <<EOS
<?xml version="1.0" encoding="UTF-8"?>
  <xrds:XRDS xmlns:xrds="xri://$xrds" xmlns="xri://$xrd*($v*2.0)">
    <XRD>
    <Service priority="0">
      #{type_str}
      <URI>#{url_for(:controller => 'open_ids', :only_path => false)}</URI>
    </Service>
  </XRD>
</xrds:XRDS>
EOS
    response.headers['content-type'] = 'application/xrds+xml'
    render :text => yadis
  end

  def add_sreg(oidreq, oidresp)
    # check for Simple Registration arguments and respond
    sregreq = OpenID::SReg::Request.from_openid_request(oidreq)
    return if sregreq.nil?
    # In a real application, this data would be user-specific,
    # and the user should be asked for permission to release
    # it.
    sreg_data = {
      'nickname' => session[:username],
      'fullname' => 'Mayor McCheese',
      'email' => 'mayor@example.com'
    }
    sregresp = OpenID::SReg::Response.extract_response(sregreq, sreg_data)
    oidresp.add_extension(sregresp)
  end

  def add_pape(oidreq, oidresp)
    papereq = OpenID::PAPE::Request.from_openid_request(oidreq)
    return if papereq.nil?
    paperesp = OpenID::PAPE::Response.new
    paperesp.nist_auth_level = 0 # we don't even do auth at all!
    oidresp.add_extension(paperesp)
  end

  def render_response(oidresp)
    if oidresp.needs_signing
      signed_response = server.signatory.sign(oidresp)
    end
    web_response = server.encode_response(oidresp)
    case web_response.code
    when HTTP_OK
      render :text => web_response.body, :status => 200
    when HTTP_REDIRECT
      redirect_to web_response.headers['location']
    else
      render :text => web_response.body, :status => 400
    end
  end

end