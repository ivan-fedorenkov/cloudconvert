require 'cloudconvert/version'
require 'cloudconvert/configuration'
require 'cloudconvert/session'
require 'cloudconvert/utils'

module Cloudconvert
  CLOUDCONVERT_URL = "https://api.cloudconvert.org"
  API_KEY_ERROR = "API key is not configured"
  CONNECTION_ERROR = "Response code was not HTTP:OK"

  Cloudconvert.configure
end