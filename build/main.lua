local network = require('network')

local NetworkRequest = require('net_req')

local url = "http://www.err4Borked.com"
local method = "GET"
local networkListener = function( evt )
  print( evt.phase )
  if evt.phase == 'ended' then
    if evt.response then
      print('roko')
      --print( evt.response )
    end
  end
end

local options = { path = "/?q=dog" }
-- --
-- -- local network_id = network.request( url, method, networkListener, options )
--
--
local req = NetworkRequest.new( url, networkListener, options )
req:run()
--
-- timer.performWithDelay( 2000, function() req:stop(); end )

-- local id = network.request( url, networkListener, options )
