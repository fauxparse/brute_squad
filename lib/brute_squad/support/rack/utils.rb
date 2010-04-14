if Rack.version.to_f < 1.1
  Rack::Utils.module_eval do
    def set_cookie_header!(header, key, value)
      case value
      when Hash
        domain  = "; domain="  + value[:domain] if value[:domain]
        path    = "; path="    + value[:path]   if value[:path]
        # According to RFC 2109, we need dashes here.
        # N.B.: cgi.rb uses spaces...
        expires = "; expires=" + value[:expires].clone.gmtime.
          strftime("%a, %d-%b-%Y %H:%M:%S GMT") if value[:expires]
        secure = "; secure"  if value[:secure]
        httponly = "; HttpOnly" if value[:httponly]
        value = value[:value]
      end
      value = [value] unless Array === value
      cookie = escape(key) + "=" +
        value.map { |v| escape v }.join("&") +
        "#{domain}#{path}#{expires}#{secure}#{httponly}"

      case header["Set-Cookie"]
      when Array
        header["Set-Cookie"] << cookie
      when String
        header["Set-Cookie"] = [header["Set-Cookie"], cookie]
      when nil
        header["Set-Cookie"] = cookie
      end

      nil
    end
    module_function :set_cookie_header!
  end
end