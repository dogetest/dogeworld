-----------------------------------------------------------------------------
-- JSONRPC4MinetestLua: JSONRPC4Lua modified for minetest engine.
-- json-rpc Module.
-- This module is released under the MIT License (MIT).
--
-- Requires JSON4MinetestLua to be installed.
-- 
-- USAGE:
-- This module exposes two functions:
--   rpc.proxy( 'url', callback)
--     Returns a proxy object for calling the 
--     JSON RPC Service at the given url with
--     given callback.
--   rpc.call ( 'url', 'method', callback, ...)
--     Calls the JSON RPC server at the given url, 
--     invokes the appropriate method, and passes the
--     remaining parameters. Minetest HTTPApiTable is
--     used to fetch pages and calls a callback.
--     Callback function receives result from 
--     decoded httpResponse.data as callback(res)

rpc = {}
local http = minetest.request_http_api()

function rpc.call(url, method, callback, ...)
  local jsonRequest = json.encode(
    {
      ["id"]=tostring(math.random()),
      ["method"] = method,
      ["params"] = {...},
    }
  )
  --debug
  --minetest.debug("jsonRequest: "..jsonRequest)
  http.fetch(
    {
      ['url'] = url,
      ['method'] = 'POST',
      ['extra_headers'] = { 
        ['content-type']='application/json-rpc', 
        ['content-length']=string.len(jsonRequest)},
      ['post_data'] = jsonRequest
    },
    function(httpResponse)
      if httpResponse.code ~= 200 then
        return
      end
      if not callback then
        return
      end
      local data = json.decode(httpResponse.data)
      local res = data.result
      callback(res)
    end)
end

function rpc.proxy(url, callback)
  local serverProxy = {}
  local proxyMeta = {
    __index = function(self, key)
      return function(...)
        return rpc.call(url, key, callback, ...)
      end
    end
  }
  setmetatable(serverProxy, proxyMeta)
  return serverProxy
end
