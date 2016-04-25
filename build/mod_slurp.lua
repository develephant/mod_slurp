--==============================================================--
--== Slurp Module for Corona SDK
--== Version 16.4.25.0
--== (c)2015 C. Byerley - chris@coronalabs.com
--==============================================================--
local Prototype = require('CoronaPrototype')
local network = require('network')
local timer = require('timer')

local Slurp = Prototype:newClass("Slurp")
function Slurp:initialize( init_tbl )
  self.urls = init_tbl.urls or {}
  self.method = init_tbl.method or "GET"
  self.timeout = init_tbl.timeout or 5000
  self.options = init_tbl.options or nil

  self._onSuccess = init_tbl.onSuccess or nil
  self._onFailed = init_tbl.onFailed or nil
  self._onDone = init_tbl.onDone or nil
  self._onError = init_tbl.onError or nil

  self._debug_mode = init_tbl.debug or false

  self.timeout_id = nil
  self.network_id = nil
end

function Slurp:timedout( url )
  self:_debug("Timeout [" .. url .. "]")
  network.cancel( self.network_id )
  self:pump()
end

function Slurp:failed( url, status )
  timer.cancel( self.timeout_id )
  self:_debug("Failed ~> " .. url .. "[" .. status .. "]")
  if self.onFailed then
    self._onFailed( url, status )
  end
  self:pump()
end

function Slurp:callback( content, url, status )
  if status and status >= 200 and status < 400 then
    self:done()
    if self._onSuccess then
      self._onSuccess( content, url, status )
    end
  else
    self:failed( url, status )
  end
end

function Slurp:done()
  timer.cancel( self.timeout_id )
  if self._onDone then
    self._onDone()
  end
  self:_debug("=> Done!")
end

function Slurp:pump()
  local url = table.remove( self.urls, 1 )
  if url then

    self:_debug("Trying -> " .. url)
    self.timeout_id = timer.performWithDelay( self.timeout, function() self:timedout( url ); end )

    local listener, callback = nil
    callback = function( ... ) self:callback( ... ); end
    listener = function( evt )
      timer.cancel( self.timeout_id )

      if evt.isError then
        if self._onError then
          self._onError( url )
        end
        self:_debug( "Network Error! ["..url.."]" )
        self:pump()
      else
        callback( evt.response, url, evt.status )
      end
    end
    self.network_id = network.request( url, self.method, listener, self.options )

  else
    self:done()
  end
end

function Slurp:cancel()
  timer.cancel( self.timeout_id )
  network.cancel( self.network_id )
  self:_debug("Canceled!")
end

function Slurp:_debug( entry )
  if self._debug_mode and entry then
    print(' ')
    print("::Slurp Debug")
    print( entry )
    print("------------------------------------------------------------")
  end
end

function Slurp:run()
  self:pump()
end

return Slurp
