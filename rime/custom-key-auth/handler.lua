local kong = kong
local http = require "resty.http"

local KeyAuthHandler = {
  PRIORITY = 1003,
  VERSION = "2.4.0",
}


local _realm = 'Key realm="' .. _KONG._NAME .. '"'

local function do_authentication(conf)
  local headers = kong.request.get_headers()
  local key = headers[conf.token_header]

  -- this request is missing an API key, HTTP 401
  if not key or key == "" then
    kong.response.set_header("WWW-Authenticate", _realm)
    return nil, { status = 401, message = "No API key found in request" }
  end

  local httpc = http:new()
  local res, err = httpc:request_uri(conf.validation_endpoint, {
  	method = "POST",
  	ssl_verify = false,
  	headers = {
  	    ["Content-Type"] = "application/json",
  	    ["rime-api-key"] = key
  	}
  })
  if not res or err then
    return nil, { status = 500, message = "Could not connect validation_endpoint" }
  end
  if res.status ~= 200 then
    if res.body ~= nil then
        return nil, { status = res.status, message = res.body, grpc_message=res.body}
    end
    return nil, { status = res.status, message = "Unauthenticated" }
  end
  -----------------------------------------
  -- Success, this request is authenticated
  -----------------------------------------
  for i = 1, #conf.map_headers do
    local mapping = conf.map_headers[i]
    local source_header, dest_header = mapping:match("^([^:]+):*(.-)$")
    local header_value = res.headers[source_header] or ""
    kong.service.request.set_header(dest_header, header_value)
  end
  return true, nil
end


function KeyAuthHandler:access(conf)
  local ok, err = do_authentication(conf)
  if not ok then
      if err.grpc_message then
        kong.response.set_header("grpc-message", err.grpc_message)
      end
      return kong.response.error(err.status, err.message, err.headers)
    end
end


return KeyAuthHandler
