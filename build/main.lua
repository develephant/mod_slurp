local network = require('network')
local NetworkRequest = require('net_req')
local url = "https://www.google.com"
local method = "GET"
local networkListener = function( evt )
  print( evt.phase )
  if evt.phase == 'ended' then
    if evt.response then
      print('response')
      --print( evt.response )
    end
  end
end
local options = { path = "/?q=dog" }
--
-- local network_id = network.request( url, method, networkListener, options )


local req = NetworkRequest.new( url, method, networkListener, options )
req:run()

timer.performWithDelay( 2000, function() req:stop(); end )
