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

class MakeLinks < ActiveRecord::Migration
  # I kept encountering an error where the links table was not created
  def self.create_links_table
    create_table(:links) do |t|
      t.column :token, :text
      t.column :url, :text
    end
  end
end

class Link # < ActiveRecord::Base
  # Insert a url with a unique token into the links database.
  attr_reader :url_token, :url_full
  def initialize(url_input)
    @url_full = url_input
  end
  def url_token
    # FIXME: The following method does not ensure the uniqueness of tokens.
    @url_token = rand(36**8).to_s(36)
  end
end

get '/' do
    form

end

post '/new' do
   url = request.body.read.slice(4, 500) # Arbitrary limit set on URL length, may be helpful in case someone tries to spam maliciously
   entry = Link.new(url)
end

get '/jquery.js' do
    send_file 'jquery.js'
end

####################################################
####  Implement Routes to make the specs pass ######
####################################################
