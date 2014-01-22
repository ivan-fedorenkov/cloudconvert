require "net/http"
require "net/http/post/multipart"
require "json"
require "yaml"
require "openssl"

module Cloudconvert
  class Session 
    attr_accessor :cloudconvert_uri, :input_format, :output_format

    def initialize(input_format, output_format)
      res = Net::HTTP.post_form(URI.parse(CLOUDCONVERT_URL + "/process"), 
        'inputformat' => input_format.to_s, 
        'outputformat' => output_format.to_s, 
        'apikey' => Session.api_key)

      raise_error_if_res_code_not_200(res)

      @cloudconvert_uri = URI("https:" + JSON.parse(res.body)["url"])
      @input_format = input_format
      @output_format = output_format
    end
    
    def upload(file_path)
      File.open(file_path, "rb") { |file| upload_file(file, file_path) }        
    end

    def upload_file(file, file_path)
      req = Net::HTTP::Post::Multipart.new @cloudconvert_uri.path + "?outputformat=#{@output_format}",
        "file" => UploadIO.new(file, "text/plain", file_path)

      res = cloudconvert_http.start do |http|
        http.request(req)
      end
      raise_error_if_res_code_not_200(res)
    end
  
    def status
      res = cloudconvert_http.start do |http|
        req = Net::HTTP::Get.new @cloudconvert_uri
        http.request(req)
      end
      raise_error_if_res_code_not_200(res)
  
      JSON.parse(res.body)
    end

    def wait_until_complete_and
      current_status = {}
      begin
        current_status = status()
        # current_percents = current_status["percent"].to_f
      end until (current_status["step"].to_s == "finished")
      # and (current_percents == 100.0)

      yield(current_status)
    end
  
    def wait_until_complete_and_download
      wait_until_complete_and do |status|
        download_uri = URI("https:" + status["output"]["url"])
        cloudconvert_http(download_uri).start do |http|
          req = Net::HTTP::Get.new download_uri
          res = http.request(req)
          raise_error_if_res_code_not_200(res)
          yield(res.body)
        end
      end

    end
  
  private
    def cloudconvert_http(uri = @cloudconvert_uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.port == 443
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if http.use_ssl?
      return http
    end

    def raise_error_if_res_code_not_200(res)
      raise "#{CONNECTION_ERROR}: #{res.to_s}" unless res.code == "200"
    end

    def self.api_key
      raise API_KEY_ERROR if Cloudconvert.configuration.api_key.nil?
      Cloudconvert.configuration.api_key
    end
  end
end
