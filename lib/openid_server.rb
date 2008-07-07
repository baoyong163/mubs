require 'pathname'
require "openid"
require "openid/consumer/discovery"
require 'openid/extensions/sreg'
require 'openid/extensions/pape'
require 'openid/store/filesystem'

include ViewsHelper

module OpenidServer
  
  
  protected

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
<xrds:XRDS
    xmlns:xrds="xri://$xrds"
    xmlns="xri://$xrd*($v*2.0)">
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