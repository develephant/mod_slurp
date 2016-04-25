--==============================================================--
--== Slurp Demo/Test
--== (c)2016 C. Byerley - chris@coronalabs.com
--==============================================================--

--== Load Slurp Module
local Slurp = require('mod_slurp')

--== Gather URLs
urls =
{
  'somemisplacedtext', --< not a url, fail
  'http://www.err4Borked.com', --< doesnt exist, fail
  'https://coronium.io', --< no cert on https, fail
  'http://www.coronium.io:9000', --< timeout, fail
  'https://www.google.com', --< Success! (99.9% of the time)
  'https://www.yahoo.com' --< won't fire unless Google is down
}

--== Create Network Callback
local onSuccess = function( content, url, status )
  print("SUCCESS")
  print( status )
  print( url )
  print( string.sub( content, 1, 500 ) ) --< trim for demo
end

local onFailed = function( url, status )
  print("FAILED")
  print( status )
  print( url )
end

local onError = function( url )
  print("ERROR")
  print( url )
end

local onDone = function()
  print("ALL DONE")
end

--== Create a new Slurp instance
local s = Slurp:new({
  urls = urls, -- Table array of URLs
  onSuccess = onSuccess, -- The callback on success
  onFailed = onFailed, -- The callback when no valid data is found
  onError = onError, -- A network error occurred
  onDone = onDone, -- The queue has finished running
  debug = true -- Show debug output in the console
})

--== Run the Slurp instance
-- Results are returned in the
-- networkCallback function
s:run()
