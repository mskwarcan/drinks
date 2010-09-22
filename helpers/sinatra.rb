helpers do
  def logged_in?
    return true if session[:user]
    nil
  end

  def link_to(name, location, alternative = false)
    if alternative and alternative[:condition]
      "<a href=#{alternative[:location]}>#{alternative[:name]}</a>"
    else
      "<a href=#{location}>#{name}</a>"
    end
  end

  def random_string(len)
   chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
   str = ""
   1.upto(len) { |i| str << chars[rand(chars.size-1)] }
   return str
  end

  def flash(msg)
    session[:flash] = msg
  end

  def show_flash
    if session[:error]
      tmp = session[:error]
      session[:error] = false
      "<div class=\"sessionError flash\"><table><tr><td><img src=\"../images/error.png\" /></td><td><p>#{tmp}</p></td></tr></table</div>"
    else
      if session[:flash]
        tmp = session[:flash]
        session[:flash] = false
        "<div class=\"success flash\"><table><tr><td><img src=\"../images/success.png\" /></td><td><p>#{tmp}</p></td></tr></table</div>"
      end
    end
  end
end