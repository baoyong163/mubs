# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery :secret => 'c71d035f25b00af2ff020c1172e5441b'

  # lib/authenticated_system
  include AuthenticatedSystem
  
  # layout 'main'

  # Globalize插件设置语言
  before_filter :init_page, :set_locale#, :account_required

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
      # if @user
        # redirect_to user_path(@user) if session[:flag] == nil #request.subdomains.last != @user.subdomain
        # session[:flag] = 1
      # end
    end
  end
  
end
