--==============================================================--
--== Slurp Module
--== (c)2016 C. Byerley - chris@coronalabs.com
--==============================================================--
local Prototype = require( "CoronaPrototype" )

local SlurpQueue = Prototype:newClass("SlurpQueue")
function SlurpQueue:initialize( init_tbl )
  print('Slurp!')

  self.callback = init_tbl.callback or nil
  self.debug = init_tbl.debug or false
  self.options = init_tbl.options or nil
  self.timeout = init_tbl.timeout or 5000
  self.breather = init_tbl.breather or 555

  self.timer_id = nil
  self.network_id = nil
  self.processing_url = nil
  self.queue = init_tbl.urls or {}
end

function SlurpQueue:run()
  if self.timer_id then
    timer.cancel( self.timer_id )
  end

  if self.network_id then
    network.cancel( self.network_id )
  end

  if self:count() > 0 then
    self:_debug("Running Queue")
    self:list()
    local url = self:pop()
    self.processing_url = url
    local listener = function( evt )
      if evt.status >= 0 then
        if evt.status >= 200 and evt.status < 400 then
          self:_debug(self.processing_url .. " Success! [" .. evt.status .. "]")
          self.callback( evt )
          self:_done()
        else
          self:doNext( evt )
        end
      else
        self:doNext( evt )
      end
    end
    self:_debug("Processing URL ".. self.processing_url)
    self.timer_id = timer.performWithDelay( self.timeout, function() self:doNext( {status = -99} ); end)
    self.network_id = network.request( url, listener, self.options )
  else
    self:_done()
  end
end

function SlurpQueue:stop()
  if self.network_id then
    network.cancel( self.network_id )
    self:_done()
  end
end

function SlurpQueue:doNext( evt )
  --tiny breath
  self:_debug("Skipping " .. self.processing_url .. " [" .. evt.status .. "]")
  timer.performWithDelay( self.breather, function() self:run(); end )
end

function SlurpQueue:add( url )
  self:_debug("Added " .. url )
  table.insert( self.queue, url )
end

function SlurpQueue:pop()
  return table.remove( self.queue, 1 )
end

function SlurpQueue:get()
  return self.queue
end

function SlurpQueue:count()
  local scnt = tostring(#self.queue)
  self:_debug("Queue Count: " .. scnt )
  return #self.queue
end

function SlurpQueue:list()
  if self.debug then
    local n = 0
    for _, url in pairs( self.queue ) do
      n = n + 1
      print( n .. '. ' .. url )
    end
  end
end

function SlurpQueue:_done()
  timer.cancel( self.timer_id )
  self:_debug("Done")
end

function SlurpQueue:_debug( entry )
  if self.debug and entry then
    print( entry )
  end
end

return SlurpQueue
