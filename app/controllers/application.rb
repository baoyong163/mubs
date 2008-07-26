# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery :secret => 'c71d035f25b00af2ff020c1172e5441b'

  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password

  # lib/authenticated_system.rb
  include AuthenticatedSystem

  # lib/openid_server_system.rb
  include OpenidServerSystem

  # Globalize插件设置语言
  before_filter :init_page, :set_locale#, :account_required

  rescue_from ActiveRecord::RecordNotFound, ActionController::UnknownAction, 
  :with => :render_404
  rescue_from ActionController::InvalidAuthenticityToken, :with => :render_422

  helper_method :endpoint_url, :scheme

  protected

  # Will either fetch the current account or return nil if none is found
  # def current_account
  #   @account ||= User.find_by_subdomain(current_subdomain)
  # end
  # # Make this method visible to views as well
  # helper_method :current_account
  # 
  # # This is a before_filter we'll use in other controllers
  # def account_required
  #   unless current_account
  #     flash[:error] = "Could not find the account '#{current_subdomain}'" 
  #     redirect_to root_path(:subdomain => false)
  #   end
  # end

  def find_subdomain
    if !request.subdomains.empty?
      unless @user = User.find_by_subdomain(request.subdomains.last)
        @blog = Blog.find_by_subdomain(request.subdomains.last)
      end
    end
  end

  def render_404
    render_error(404)
  end

  def render_422
    render_error(422)
  end

  def render_500
    render_error(500)
  end

  def render_error(status_code)
    render :file => "#{RAILS_ROOT}/public/#{status_code}.html", :status => status_code
  end

  private
  def init_page
    session[:user] = 'users'
  end

  # Globalize插件设置语言
  # Will set the session 'locale' if (and only if) an explicit parameter 'locale'
  # is passed (and is acceptable)
  # If no session exists, we look through the list of desired languages for the
  # first one we can accept.
  def set_locale
    accept_locales = LOCALES.keys # change this line as needed, must be an array of strings
    session[:locale] = params[:locale] if accept_locales.include?(params[:locale])
    Locale.set(session[:locale] || (request.env["HTTP_ACCEPT_LANGUAGE"] || "").scan(/[^,;]+/).find{|l| accept_locales.include?(l)})
  end

  def set_timezone
    if logged_in?
      Time.zone = current_user.time_zone
    else
      Time.zone = 'UTC'
    end
  end

  # OpenID endpoint url  
  def endpoint_url
    server_url(:protocol => scheme)
  end

  def scheme
    # APP_CONFIG['use_ssl'] ? 'https' : 'http'
    'http'
  end

end
