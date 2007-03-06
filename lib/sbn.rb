# = sbn.rb - Simple Bayesian Networks for Ruby
#
# Copyright (C) 2006-2007  Carl Youngblood
#
# Carl Youngblood mailto:carl@youngbloods.org
#
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

require 'rubygems'
require 'active_support'
gem 'builder', '>=2.0'
require 'builder'

Dir[File.join(File.dirname(__FILE__), '*.rb')].sort.each { |lib| require lib unless lib == 'sbn.rb' }