require 'sinatra'
require "sinatra/reloader" if development?
require 'active_record'
require 'pry'

configure :development, :production do
    ActiveRecord::Base.establish_connection(
       :adapter => 'sqlite3',
       :database =>  'db/dev.sqlite3.db'
     )
end


# Quick and dirty form for testing application
#
# If building a real application you should probably
# use views: 
# http://www.sinatrarb.com/intro#Views%20/%20Templates
form = <<-eos
    <form id='myForm'>
        <input type='text' name="url">
        <input type="submit" value="Shorten"> 
    </form>
    <h2>Results:</h2>
    <h3 id="display"></h3>
    <script src="jquery.js"></script>

    <script type="text/javascript">
        $(function() {
            $('#myForm').submit(function() {
            $.post('/new', $("#myForm").serialize(), function(data){
                $('#display').html(data);
                });
            return false;
            });
    });
    </script>
eos

# Models to Access the database 
# through ActiveRecord.  Define 
# associations here if need be
#
# http://guides.rubyonrails.org/association_basics.html

class Link < ActiveRecord::Base
  # Insert a url with a unique token into the links database.
  self.table_name = "links"
  belongs_to :links
  def initialize_after(url_input, url_token)
    @url = url_input
    @token = url_token
    update_attribute(:token, @url_input)
    update_attribute(:url, @url_token)
  end
end

# For some reason it was very difficult to query through ActiveRecord, so stored values here.
local_db = {}

Link.all.each do |link|
  local_db[link.token] = link.url
end

get '/' do
  links = Link.all

  output = "<h2>Links already generated:</h2>"
  links.each do |link|
    output << "<a href='#{link.token}'>#{link.url}</a><br />"
  end

  return form + output

end

post '/new' do
  request_data = request.body.read.slice(4, 500) # Arbitrary limit set on URL length, may be helpful in case someone tries to spam maliciously
  short_url = rand(36**8).to_s(36)
  body "/#{short_url}" # return shortened URL to user -- see specs.
  exists = true if local_db.has_value?(request_data)
  Link.find_or_create_by_url(request_data, :token => short_url) unless exists
  local_db[short_url] = request_data
end

get '/jquery.js' do
    send_file 'jquery.js'
end

####################################################
####  Implement Routes to make the specs pass ######
####################################################



get '/:short_url' do
  if local_db[params[:short_url]]
    # FIXME: Handle urls that already have http:// or https://
    redirect "http://#{local_db[params[:short_url]]}"
  else
    pass
  end
end