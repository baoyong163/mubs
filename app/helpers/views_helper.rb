module ViewsHelper
  
  # acts_as_taggable_on_steroids 提供的 tag cloud helper
  include TagsHelper
  
  # html页面title
  def title(page_title)
    content_for(:title){page_title}
  end
  
  def idn_url(ascii_url)
    'http://' + Idna.toUnicode(ascii_url.gsub(/[a-zA-Z]+:\/\//,''))
  end
  
  def url_for_user
    # url_for :controller => 'user', :action => session[:username]
    
    'http://'+ @user.subdomain + '.' + request.domain + request.port_string
  end

end