require "net/http"
require "net/http/post/multipart"
require "json"
require "yaml"
require "openssl"

module Cloudconvert
  class Session 
    attr_accessor :cloudconvert_uri
  
    def initialize
      config = YAML.load_file('cloudconvert.yml')
      @cloudconvert_api_key = config['api_key']
    end
  
    def start(inputformat, outputformat)
      resp = Net::HTTP.post_form(
        URI.parse('https://api.cloudconvert.org/process'),
        'inputformat' => inputformat.to_s, 'outputformat' => outputformat, 'apikey' => @cloudconvert_api_key)
  
      @cloudconvert_uri = URI("https:" + JSON.parse(resp.body)["url"])
      @input_format = inputformat
      @output_format = outputformat
    end
  
    def upload(file_path)
      File.open(file_path, "rb") do |file|
        req = Net::HTTP::Post::Multipart.new @cloudconvert_uri.path + "?outputformat=#{@output_format}&email=1",
          "file" => UploadIO.new(file, "text/plain", file_path)
  
        res = cloudconvert_http.start do |http|
          http.request(req)
        end
      end
    end
  
    def status
      resp = cloudconvert_http.start do |http|
        req = Net::HTTP::Get.new @cloudconvert_uri
        http.request(req)
      end
  
      JSON.parse(resp.body)
    end
  
    def wait_until_complete_and_download_to(result_filepath = nil, debug_mode = false)
      current_status = {}
      begin
        current_status = status()
        puts current_status.to_s if debug_mode
        current_percents = current_status["percent"].to_f
        current_phase = current_status["step"].to_s
      end until ((current_phase == "finished") and (current_percents == 100.0))
  
      download_uri = URI("https:" + current_status["output"]["url"])
      result_filepath ||= current_status["output"]["filename"]
  
      cloudconvert_http(download_uri).start do |http|
        req = Net::HTTP::Get.new download_uri
        resp = http.request(req)
        open(result_filepath, "wb") do |file|
          file.write(resp.body)
        end
      end
  
      puts "Successfully downloaded and saved file: #{result_filepath}!"
    end
  
  private
    def cloudconvert_http(uri = @cloudconvert_uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.port == 443
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if http.use_ssl?
      return http
    end
  end
end
