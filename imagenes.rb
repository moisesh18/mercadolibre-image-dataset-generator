$stdout.sync = true
require 'sinatra'
require 'httparty'
require 'dotenv'
require 'rubygems'
require 'meli'
require 'json'
require "open-uri"

class GiftBasket < Sinatra::Base
  attr_reader :tokens

  #meli
  APP_ID = 8357875269029285
  APP_SECRET = "DfjYyjbqO9HDAOQOKmP89NWfsMapPfm2"
  APP_URL = "44705bb2.ngrok.io"
  ACCESS_TOKEN = nil
  REFRESH_TOKEN = nil
  $resultado = 0
  meli = Meli.new(APP_ID, "#{APP_SECRET}")
  disable :reload

  def initialize
    @tokens = {}
    super
  end

  get '/login' do
    install_url = "#{meli.auth_url("https://#{APP_URL}/authorize")}"
    redirect install_url
  end

  get '/authorize' do
    content_type :text
    meli.authorize(params["code"], "https://#{APP_URL}/authorize")
    #Don't Forget to Save this data!
    ACCESS_TOKEN = meli.access_token
    REFRESH_TOKEN = meli.refresh_token
    puts "Autenticación de Meli realizada correctamente! Token: #{meli.access_token} RefresToken: #{meli.refresh_token}"
    get_all_products
    install_url = "https://#{APP_URL}/dataset"
    redirect install_url  
  end           

  get '/dataset' do
    content_type :json
    $resultado
  end 


  helpers do




    def get_all_products
        total = 1
        var = 0	
		meli = Meli.new(APP_ID, "#{APP_SECRET}", "#{ACCESS_TOKEN}", "#{REFRESH_TOKEN}")                   
		user = meli.get("/users/me?access_token=#{ACCESS_TOKEN}")
		res = JSON.parse user.body
		user_id = res["id"]
    dataset = Hash.new
		query1 = "iphone 4S"
    num = 0
		#ipad air
    #chromecast

    puts "------------------Buscando el dataset-----------------------"
    while total > var
      puts "------------------entroo-----------------------"
      productsmeli = meli.get("/sites/MLM/search?q=#{query1}&offset=#{var}")
      res = JSON.parse productsmeli.body      
      total = res["paging"]["total"]
      res["results"].each do |producto|
        query = meli.get("items/#{producto["id"]}?access_token=#{ACCESS_TOKEN}")
        res = JSON.parse query.body
        unless res["pictures"][0].nil?

            if res["attributes"][0]!=nil && res["attributes"][0]["value_name"]=="Apple"
                puts "#{num}" 
                url = res["pictures"][0]["url"]
                File.open("#{num}.jpg", "wb") do |f| 
                  f.write HTTParty.get(url).body
                end
                puts "Producto terminado"
                num = num+1
            end

        end
      end
      var = var+50
      puts "Pagina terminada"
      end
    puts "------------------termino de buscar el dataset-----------------------"
		  #bundle exec ruby dataset.rb
      #./ngrok http 4567

=begin      

=end
    end
  end
end
run GiftBasket.run!