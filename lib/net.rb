# = SBN: Simple Bayesian Networks
# Copyright (C) 2005-2007  Carl Youngblood mailto:carl@youngbloods.org
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
# 
# == Example
#
# === Get Form Values
#
#  require "cgi"
#  cgi = CGI.new
#  values = cgi['field_name']   # <== array of 'field_name'
#    # if not 'field_name' included, then return [].
#  fields = cgi.keys            # <== array of field names
#
#  # returns true if form has 'field_name'
#  cgi.has_key?('field_name')
#  cgi.has_key?('field_name')
#  cgi.include?('field_name')
#
#
# === GET FORM VALUES AS HASH
#
#  require "cgi"
#  cgi = CGI.new
#  params = cgi.params
#
# cgi.params is a hash.
#
#  cgi.params['new_field_name'] = ["value"]  # add new param
#  cgi.params['field_name'] = ["new_value"]  # change value
#  cgi.params.delete('field_name')           # delete param
#  cgi.params.clear                          # delete all params
#
#
# === SAVE FORM VALUES TO FILE
#
#  require "pstore"
#  db = PStore.new("query.db")
#  db.transaction do
#    db["params"] = cgi.params
#  end
#
#
# === RESTORE FORM VALUES FROM FILE
#
#  require "pstore"
#  db = PStore.new("query.db")
#  db.transaction do
#    cgi.params = db["params"]
#  end
#
#
# === GET MULTIPART FORM VALUES
#
#  require "cgi"
#  cgi = CGI.new
#  values = cgi['field_name']   # <== array of 'field_name'
#  values[0].read               # <== body of values[0]
#  values[0].local_path         # <== path to local file of values[0]
#  values[0].original_filename  # <== original filename of values[0]
#  values[0].content_type       # <== content_type of values[0]
#
# and values[0] has StringIO or Tempfile class methods.
#
#
# === GET COOKIE VALUES
#
#  require "cgi"
#  cgi = CGI.new
#  values = cgi.cookies['name']  # <== array of 'name'
#    # if not 'name' included, then return [].
#  names = cgi.cookies.keys      # <== array of cookie names
#
# and cgi.cookies is a hash.
#
#
# === GET COOKIE OBJECTS
#
#  require "cgi"
#  cgi = CGI.new
#  for name, cookie in cgi.cookies
#    cookie.expires = Time.now + 30
#  end
#  cgi.out("cookie" => cgi.cookies){"string"}
#
#  cgi.cookies # { "name1" => cookie1, "name2" => cookie2, ... }
#
#  require "cgi"
#  cgi = CGI.new
#  cgi.cookies['name'].expires = Time.now + 30
#  cgi.out("cookie" => cgi.cookies['name']){"string"}
#
# and see MAKE COOKIE OBJECT.
#
#
# === GET ENVIRONMENT VALUE
#
#  require "cgi"
#  cgi = CGI.new
#  value = cgi.auth_type
#    # ENV["AUTH_TYPE"]
#
# see http://www.w3.org/CGI/
#
# AUTH_TYPE CONTENT_LENGTH CONTENT_TYPE GATEWAY_INTERFACE PATH_INFO
# PATH_TRANSLATED QUERY_STRING REMOTE_ADDR REMOTE_HOST REMOTE_IDENT
# REMOTE_USER REQUEST_METHOD SCRIPT_NAME SERVER_NAME SERVER_PORT
# SERVER_PROTOCOL SERVER_SOFTWARE
#
# content_length and server_port return Integer. and the others return String.
#
# and HTTP_COOKIE, HTTP_COOKIE2
#
#  value = cgi.raw_cookie
#    # ENV["HTTP_COOKIE"]
#  value = cgi.raw_cookie2
#    # ENV["HTTP_COOKIE2"]
#
# and other HTTP_*
#
#  value = cgi.accept
#    # ENV["HTTP_ACCEPT"]
#  value = cgi.accept_charset
#    # ENV["HTTP_ACCEPT_CHARSET"]
#
# HTTP_ACCEPT HTTP_ACCEPT_CHARSET HTTP_ACCEPT_ENCODING HTTP_ACCEPT_LANGUAGE
# HTTP_CACHE_CONTROL HTTP_FROM HTTP_HOST HTTP_NEGOTIATE HTTP_PRAGMA
# HTTP_REFERER HTTP_USER_AGENT
#
#
# === PRINT HTTP HEADER AND HTML STRING TO $DEFAULT_OUTPUT ($>)
#
#  require "cgi"
#  cgi = CGI.new("html3")  # add HTML generation methods
#  cgi.out() do
#    cgi.html() do
#      cgi.head{ cgi.title{"TITLE"} } +
#      cgi.body() do
#        cgi.form() do
#          cgi.textarea("get_text") +
#          cgi.br +
#          cgi.submit
#        end +
#        cgi.pre() do
#          CGI::escapeHTML(
#            "params: " + cgi.params.inspect + "\n" +
#            "cookies: " + cgi.cookies.inspect + "\n" +
#            ENV.collect() do |key, value|
#              key + " --> " + value + "\n"
#            end.join("")
#          )
#        end
#      end
#    end
#  end
#
#  # add HTML generation methods
#  CGI.new("html3")    # html3.2
#  CGI.new("html4")    # html4.01 (Strict)
#  CGI.new("html4Tr")  # html4.01 Transitional
#  CGI.new("html4Fr")  # html4.01 Frameset

class Sbn
  class Net
    attr_reader :name, :variables
    
    def initialize(name = '')
      @@net_count ||= 0
      @@net_count += 1
      @name = (name.empty? ? "net_#{@@net_count}" : name.to_underscore_sym)
      @variables = {}
      @evidence = {}
    end

    def ==(obj); test_equal(obj); end
    def eql?(obj); test_equal(obj); end
    def ===(obj); test_equal(obj); end
  
    def add_variable(variable)
      name = variable.name
      if @variables.has_key? name
        raise "Variable of same name has already been added to this net"
      end
      @variables[name] = variable
    end
    
    def symbolize_evidence(evidence)
      newevidence = {}
      evidence.each do |key, val|
        key = key.to_underscore_sym
        newevidence[key] = @variables[key].transform_evidence_value(val)
      end
      newevidence
    end
    
    def set_evidence(event)
      @evidence = symbolize_evidence(event)
    end

  private
    def test_equal(net)
      returnval = true
      returnval = false unless net.class == self.class and self.class == Net
      returnval = false unless net.name == @name
      returnval = false unless @variables.keys.map {|k| k.to_s}.sort == net.variables.keys.map {|k| k.to_s}.sort
      net.variables.each {|name, variable| returnval = false unless variable == @variables[name] }
      returnval
    end
  end
end
